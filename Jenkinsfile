/*
 * This file makes two assumptions about your Jenkins build environment:
 *
 * 1.  You have nodes set up with labels of the form "docker-${ARCH}" to
 *     support the various build architectures (currently 'x86_64',
 *     's390x', 'aarch64' (ARM), and 'ppc64le').
 * 2.  If you do not want to target the 'docker.io/openwhisk' registry
 *     (and unless you're the official maintainer, you shouldn't), then
 *     you've set up an OPENWHISK_TARGET_REGISTRY variable with the target
 *     registry you'll use.
 *
 * TODO:  Set up the build architectures as a parameter that will drive
 *        a scripted loop to build stages.
 */

/*
 *  There may be a problem with parallelism and competing logins to the docker
 *  registry.  Is there a way to partition that off?  Maybe in a separate step?
 */
def build_shell='''
env | grep JAVA || /bin/true
[ -n "${BOOST_VERSION_DOT}" ] || { echo "BOOST_VERSION_DOT undeclared"; exit 16; }
[ -n "${BOOST_VERSION_SCORE}" ] || { echo "BOOST_VERSION_SCORE undeclared"; exit 16; }
docker build -t boost-builder:${BOOST_VERSION_DOT}-${uname -m}
if [ -n "${DOCKER_}"]
docker tag boost-builder:${BOOST_VERSION_DOT}-${uname -m} \
  ${TARGET_REGISTRY:-docker.io}/${TARGET_PREFIX:-openwhisks390x}/boost-builder:${BOOST_VERSION_DOT}-${uname -m}
docker push ${TARGET_REGISTRY:-docker.io}/${TARGET_PREFIX:-openwhisks390x}/boost-builder:${BOOST_VERSION_DOT}-${uname -m}
'''

/*
 *  Note:  Why am I removing the Manifests directory?
 */
def manifest_shell='''
registry=${TARGET_REGISTRY:-docker.io}
prefix=${TARGET_PREFIX:-openwhisk}
rm -rf ~/.docker/manifests  \
for i in boost-builder; do
  docker manifest create ${registry}/${prefix}/$i:${BOOST_VERSION_DOT} \
    ${registry}/${prefix}/$i:${BOOST_VERSION_DOT}-x86_64 \
    ${registry}/${prefix}/$i:${BOOST_VERSION_DOT}-s390x \
    ${registry}/${prefix}/$i:${BOOST_VERSION_DOT}-aarch64 \
    ${registry}/${prefix}/$i:${BOOST_VERSION_DOT}-ppc64le
  docker manifest annotate --os linux --arch amd64 \
    ${registry}/${prefix}/$i:${BOOST_VERSION_DOT} \
    ${registry}/${prefix}/$i:${BOOST_VERSION_DOT}-x86_64
  docker manifest annotate --os linux --arch s390x \
    ${registry}/${prefix}/$i:${BOOST_VERSION_DOT} \
    ${registry}/${prefix}/$i:${BOOST_VERSION_DOT}-s390x
  docker manifest annotate --os linux --arch arm64 \
    ${registry}/${prefix}/$i:${BOOST_VERSION_DOT} \
    ${registry}/${prefix}/$i:${BOOST_VERSION_DOT}-aarch64
  docker manifest annotate --os linux --arch ppc64le \
    ${registry}/${prefix}/$i:${BOOST_VERSION_DOT} \
    ${registry}/${prefix}/$i:${BOOST_VERSION_DOT}-ppc64le
  docker manifest push ${registry}/${prefix}/$i:${BOOST_VERSION_DOT}
done
'''

pipeline {
  agent none
  stages {
    stage('Build') {
      parallel {
        stage("Build-x86_64") {
          agent {
            label "docker-x86_64"
          }
          steps {
            sh build_shell
          }
        }
        stage("Build-s390x") {
          agent {
            label "docker-s390x"
          }
          steps {
            sh build_shell
          }
        }
        stage("Build-aarch64") {
          agent {
            label "docker-aarch64"
          }
          steps {
            sh build_shell
          }
        }
        stage("Build-ppc64le") {
          agent {
            label "docker-ppc64le"
          }
          steps {
            sh build_shell
          }
        }
      }
    }
    stage("Manifest") {
      agent {
        // Could be anything capable of running 'docker manifest', but right
        // now only the x86_64 environment is set up for that.
       label "docker-x86_64"
      }
      steps {
        sh manifest_shell
      }
    }
  }
}
