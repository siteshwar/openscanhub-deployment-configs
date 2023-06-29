import koji
import json
import sys
import git
import os

def load_package_list():
    return open("packages.txt", "r").read().split("\n")

def get_tagged_builds(koji_proxy, tag):
    """
    Return a list of latest builds that are tagged with certain tag
    """
    return koji_proxy.listTagged(tag, latest=True)

def sync_directly(unsycned_builds):
    """
    This is a temporary method to sync by directly uploading rpms to centos repos
    This should be replaced by `sync_through_pub()` function at some point in future
    """
    for build in unsynced_builds:
        print("koji download-build --rpm " + build['nvr'] + ".src.rpm")
        os.system("koji download-build --rpm " + build['nvr'] + ".src.rpm")

    for build in unsynced_builds:
        os.system("alt-src -d --push c8s " + build['nvr'] + ".src.rpm")

    for build in unsynced_builds:
        print("Removing " + build['nvr'] + ".src.rpm...")
        os.remove(build['nvr'] + ".src.rpm")

# Badly written but working python script
if __name__ == "__main__":
    # tag = sys.argv[1]
    tag = "f37"
    koji_proxy = koji.ClientSession("https://koji.fedoraproject.org/kojihub/")
    packages_to_track = load_package_list()
    # build = koji_proxy.getTag()
    tagged_builds = get_tagged_builds(koji_proxy, tag)
    for i in tagged_builds:
        # print("Checking ", i["name"])
        if i["name"] in packages_to_track:
            print(i)
            # os.system("koji download-build --rpm " + i['nvr'] + ".src.rpm")
    # build = koji_proxy.getBuild(sys.argv[1]) # module
    # `nvr` attribute of `tagged_build` contains git tags
    # print(json.dumps(tagged_builds, indent=4, sort_keys=True, separators=[",",":"]))
    # sync_through_pub(unsynced_builds)
    # sync_directly(tagged_builds)
