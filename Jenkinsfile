#!/usr/bin/groovy

// load pipeline functions
// Requires pipeline-github-lib plugin to load library from github

@Library('github.com/lachie83/jenkins-pipeline@dev')
def pipeline = new io.estrado.Pipeline()


node {
  def app



  def pwd = pwd()
  def chart_dir = "$pwd/helm/"
  def tool_name = "suricata"
  def container_dir = "$pwd/container/"
  def custom_image = "images.suricata"
  def custom_values_url = "http://repos.sealingtech.com/cisco-c240-m5/suricata/values.yaml"
  def user_id = ''
  wrap([$class: 'BuildUser']) {
      echo "userId=${BUILD_USER_ID},fullName=${BUILD_USER},email=${BUILD_USER_EMAIL}"
      user_id = "${BUILD_USER_ID}"
  }

  sh "env"

  def container_tag = "gcr.io/edcop-dev/$user_id-$tool_name"

  stage('Clone repository') {
      /* Let's make sure we have the repository cloned to our workspace */
      checkout scm
  }


  stage('Build image') {
      /* This builds the actual image; synonymous to
       * docker build on the command line */
      println("Building $container_tag:$env.BUILD_ID")

      app = docker.build("$container_tag:$env.BUILD_ID","./container/")
  }


  stage('Push image') {
      /* Finally, we'll push the image with two tags:
       * First, the incremental build number from Jenkins
       * Second, the 'latest' tag.
       * Pushing multiple tags is cheap, as all the layers are reused. */
      docker.withRegistry('https://gcr.io/edcop-dev/', 'gcr:edcop-dev') {
          app.push("$env.BUILD_ID")
      }
  }

  stage('helm lint') {
      sh "helm lint $tool_name"
  }

  stage('helm deploy') {
      sh "helm install --set $custom_image='$container_tag:$env.BUILD_ID' --name='$user_id-$tool_name-$env.BUILD_ID' -f $custom_values_url $tool_name"
  }

  stage('sleeping 4 minutes') {
    sleep(2)
  }

  stage('Verifying running pods') {
    def number_ready=sh(returnStdout: true, script: "kubectl get ds $user_id-$tool_name-$env.BUILD_ID-$tool_name  -o jsonpath={.status.numberReady}").trim()
    def number_scheduled=sh(returnStdout: true, script: "kubectl get ds $user_id-$tool_name-$env.BUILD_ID-$tool_name  -o jsonpath={.status.currentNumberScheduled}").trim()

    if($number_ready==$number_scheduled) {
      println("Pods are running")
    } else {
      error("Some or all Pods failed")
    }
  }


  stage('Verifying engine started on first pod') {
    def command="kubectl get pods  | grep $user_id-$tool_name-$env.BUILD_ID-$tool_name | awk "+'{\'print $1\'}'+"| head -1"
    def first pod=sh(returnStdout: true, script: command)

    kubectl logs $first_pod -c suricata | grep 'engine started'
  }

  stage('running traffic') {
      sshagent(credentials: ['jenkins']) {
        sh "ssh -o StrictHostKeyChecking=no -l jenkins 172.16.250.30 'cd /trex; sudo /trex/t-rex-64  -f /trex/cap2/cnn_dns.yaml -d 60'"
      }
  }
}
