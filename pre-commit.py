#!/usr/bin/python
# coding=utf8

# Install with
# ln -sf ../../pre-commit.py .git/hooks/pre-commit

#configuration
PROJECT_NAME = "DCAKit"
WORKSPACE_NAME = "DCAKit.xcodeproj/project.xcworkspace"
TEST_SCHEME = "DCAKit"
BUILD_SCHEME = "DCAKit"
TEST_SUITE_NAME = "DCAKitTests.octest"

#no config below - paste over me

#version history
# v0.1 - submodule support
# v0.2 - improved test output regex


def getSO(cmd):
    import subprocess
    proc = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE)
    output,stderr = proc.communicate()
    proc.wait()  # this might hang with a LOT of output
    return (proc.returncode, output)


def getO(cmd):
    import subprocess
    return subprocess.check_output(cmd, shell=True)


def fail(subtitle, detail=""):
    getO("""develop-environment/terminal-notifier.app/Contents/MacOS/terminal-notifier -group "{PROJECT_NAME}" -title "⛔ {PROJECT_NAME} commit failed " -subtitle "{SUBTITLE}" -message "{MESSAGE}" -activate "com.apple.Terminal" """.format(PROJECT_NAME=PROJECT_NAME, SUBTITLE=subtitle, MESSAGE=detail))
    print subtitle
    print detail

    raise Exception("See previous errors")


def success():
    getO("""develop-environment/terminal-notifier.app/Contents/MacOS/terminal-notifier -group "{PROJECT_NAME}" -title "Commit succeeded {PROJECT_NAME}" -subtitle "{SUBTITLE}" -message "{MESSAGE}" -activate "com.apple.Terminal" """.format(PROJECT_NAME=PROJECT_NAME, SUBTITLE="", MESSAGE="😃"))

#remove any old notification
getO("""develop-environment/terminal-notifier.app/Contents/MacOS/terminal-notifier -remove "{PROJECT_NAME}" """.format(PROJECT_NAME=PROJECT_NAME))
try:
    print "Submodules check..."
    o = getO("""git submodule status""")
    for moduledescriptor in o.split("\n"):
        moduledescriptor = moduledescriptor.strip()
        if len(moduledescriptor)==0: continue
        sha = moduledescriptor.split(" ")[0]
        path = moduledescriptor.split(" ")[1]

        #verify clean status
        #we must unset GIT_INDEX_FILE since it is set by the commit hook and it interferes with our ability to get anything done
        import os
        del os.environ["GIT_INDEX_FILE"]
        o = getO("""cd {PATH} && git status --porcelain""".format(PATH=path))
        if (o!=""):
            fail("Submodule {PATH} has non-clean status {STATUS}".format(PATH=path,STATUS=o))

        sha = sha.strip("+") #this is used iff the submodule's actual HEAD is newer than what the parent repo's pointer is, which is almost always true in our workflow

        #determine if the submodule's commits are out there anywhere
        o = getO("cd {PATH} && git fetch && git branch -r --contains {SHA}".format(PATH=path,SHA=sha))
        if not "origin" in o:
            fail("{PATH} needs push".format(PATH=path),detail="Can't find ref {SHA} in remote".format(SHA=sha))

    print "Forgetting to check in files check..."
    requireArray = [".m",".h"]
    for ext in requireArray:
        (s, o) = getSO("""git status --porcelain | grep "??.*$""" + ext + '"')
        if s != 1:
            print "You have untracked files with extension", ext
            print "Commit these files, or add them to .gitgnore:"
            print o.replace("?? ", "")
            fail(subtitle="Untracked files", detail=o.replace("?? ", ""))


    print "build/analyze/warning check"
    (code,output) = getSO("xcodebuild -configuration Release -sdk iphonesimulator -workspace {WORKSPACE_NAME} -IDEBuildOperationMaxNumberOfConcurrentCompile=1 -scheme {SCHEME_NAME} RUN_CLANG_STATIC_ANALYZER=YES clean build ".format(SCHEME_NAME=BUILD_SCHEME,WORKSPACE_NAME=WORKSPACE_NAME))



    if code != 0:
        print output
        fail("Build failed","Return code %d" % code)

    import re

    if not re.search("\*\* BUILD SUCCEEDED \*\*",output):
        print output
        fail("Build did not succeed","Can't find text ** BUILD SUCCEEDED ** in output.  Can you?")


    warnings = re.findall(r".*:\d+:\d+: warning.*(?=\n)",output)
    if len(warnings) != 0:
        print output
        print "\n".join(warnings)
        fail("You have warnings",warnings[0])

    print "unit test check"
    #run the unit tests
    (code,output) = getSO("xcodebuild -sdk iphonesimulator -configuration UnitTest -workspace {WORKSPACE_NAME} -scheme {SCHEME_NAME}  RUN_UNIT_TEST_WITH_IOS_SIM=YES clean build".format(SCHEME_NAME=TEST_SCHEME,WORKSPACE_NAME=WORKSPACE_NAME))

    if code != 0:
        print output
        fail("Build failed","Return code %d" % code)


    if not re.search("\*\* BUILD SUCCEEDED \*\*",output):
        print output
        fail("Build did not succeed","Can't find text ** BUILD SUCCEEDED ** in output.  Can you?")


    regex1 = r"Test Suite '.*"+TEST_SUITE_NAME + r".*' finished at .*\nExecuted .* with (.*) failure"
    spolsky_msg = re.search(regex1,output)
    if not spolsky_msg:
        print output
        fail("Can't find the end of the app test in your build output","It looks like %s" % regex1)

    

    if not spolsky_msg.groups()[0]=="0":
        print output
        fail("%s failed %s unit tests" % (PROJECT_NAME,spolsky_msg.groups()[0]))



    success()

finally:
    try:
        pass
        #getO("""git stash pop""")
    except:
        if not stashed:
            pass
        else:
            fail("failed to pop")






