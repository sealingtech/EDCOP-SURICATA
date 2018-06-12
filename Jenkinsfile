#!/usr/bin/groovy

// load pipeline functions
// Requires pipeline-github-lib plugin to load library from github

@Library('github.com/lachie83/jenkins-pipeline@dev')
def pipeline = new io.estrado.Pipeline()


node {
  def app

  def pwd = pwd()
  def chart_dir = "$pwd/helm/"
  def container_dir = "$pwd/container/"
  wrap([$class: 'BuildUser']) {
     var build_user = ${BUILD_USER}"
  }
  
  def container_tag = "gcr.io/edcop-public/$build_user-suricata"
  def custom_image = "images.suricata"
  def custom_values_url = "http://repos.sealingtech.com/cisco-c240-m5/suricata/values.yaml"

  stage('Clone repository') {
      /* Let's make sure we have the repository cloned to our workspace */
      checkout scm
  }


  stage('Build image') {
      /* This builds the actual image; synonymous to
       * docker build on the command line */
      println("Building $container_tag:$env.BUILD_ID")

      sh "env"

      app = docker.build("$container_tag:$env.BUILD_ID","./container/")
  }


  stage('Push image') {
      /* Finally, we'll push the image with two tags:
       * First, the incremental build number from Jenkins
       * Second, the 'latest' tag.
       * Pushing multiple tags is cheap, as all the layers are reused. */
      docker.withRegistry('https://gcr.io/edcop-public/', 'gcr:edcop-public') {
          app.push("$env.BUILD_ID")
      }
  }

  stage('helm lint') {
      sh 'helm lint suricata' 
  }

  stage('helm deploy') {
      sh "helm install --set $custom_image='$container_tag:$env.BUILD_ID' -f $custom_values_url suricata"
  }
}
