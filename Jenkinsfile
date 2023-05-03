//Consolidating all those stages and building one single pipeline for the instavote app is
//called a Mono Pipe. As an exercise, use the following steps as a loose reference while
//attempting to complete this exercise on your own:
//Copy over worker/Jenkinsfile to the top level directory, i.e.
//example-voting-app/Jenkinsfile.
//Rename stages to identify with the application name. i.e. worker.
//Bring in just the stages from result/Jenkinsfile and vote/Jenkinsfile.
//Commit the changes into the repository branch created earlier, i.e.
//Create a new Multi Branch Pipeline job.
//Once you validate the pipeline, add the “deploy to dev” stage
pipeline {
  agent none
  // here it is necessary to change tags after every app update
  environment {

        TAG_VOTE   = '1.0.145' // MAJOR.MINOR.PATCH
        TAG_RESULT = '1.0.145' // MAJOR.MINOR.PATCH
        TAG_WORKER = '1.0.145' // MAJOR.MINOR.PATCH

    }

  stages {

    stage('checkout'){
          agent any
            steps{
                git branch: 'master', url: 'https://github.com/tinhutins/voting-app-lfs261.git'
            }
        }
    
    stage('worker-build') {
      agent{
                docker{
                image 'maven:3.6.1-jdk-8-slim'
                args '-v $HOME/.m2:/root/.m2'
                }
            } 
      when {
        changeset '**/worker/**'
      }
      steps {
        echo 'Compiling worker app..'
        dir(path: 'worker') {
          sh 'mvn compile'
        }

      }
    }

    stage('worker test') {
      agent{
                docker{
                image 'maven:3.6.1-jdk-8-slim'
                args '-v $HOME/.m2:/root/.m2'
                }
            } 
      when {
        changeset '**/worker/**'
      }
      steps {
        echo 'Running Unit Tets on worker app.'
        dir(path: 'worker') {
          sh 'mvn clean test'
        }

      }
    }

    stage('worker-package') {
      agent{
                docker{
                image 'maven:3.6.1-jdk-8-slim'
                args '-v $HOME/.m2:/root/.m2'
                }
            } 
      when {
        branch 'master'
        changeset '**/worker/**'
      }
      steps {
        echo 'Packaging worker app'
        dir(path: 'worker') {
          sh 'mvn package -DskipTests'
          archiveArtifacts(artifacts: '**/target/*.jar', fingerprint: true)
        }

      }
    }

    stage('worker-package-docker') {
            when{
                branch 'master'
                changeset "**/worker/**"
                }
             
            agent any
                
                steps {
                    echo 'Packaging worker app with docker'
                    script {
                    //withDockerRegistry(credentialsId: 'dockerlogin', url: 'https://registry-1.docker.io/v2/'){
                    docker.withRegistry('https://registry-1.docker.io/v2/', 'dockerlogin'){
                    def workerImage = docker.build("hutinskit/worker:v${TAG_WORKER}", "./worker")
                    workerImage.push()
                    workerImage.push("${env.BRANCH_NAME}")
                   }
                   }
                }  
    }

    stage('result-build') {
      agent{
                docker{
                image 'node:16.13.1-alpine'
                }
            } 
      when {
        changeset '**/result/**'
      }
      steps {
        echo 'Compiling result app..'
        dir(path: 'result') {
          sh 'npm install'
        }

      }
    }

    stage('result-test') {
      agent{
                docker{
                image 'node:16.13.1-alpine'
                }
            } 
      when {
        changeset '**/result/**'
      }
      steps {
        echo 'Running Unit Tests on result app..'
        dir(path: 'result') {
          sh 'npm install'
          sh 'npm test'
        }

      }
    }

     stage('result-package-docker') {
             when{
                branch 'master'
                changeset "**/result/**"
            }
             agent any
                steps {
                    echo 'Packaging result app with docker'
                    script {
                    //withDockerRegistry(credentialsId: 'dockerlogin', url: 'https://registry-1.docker.io/v2/'){
                    docker.withRegistry('https://registry-1.docker.io/v2/', 'dockerlogin'){
                    def resultImage = docker.build("hutinskit/result:v${TAG_RESULT}", "./result")
                    resultImage.push()
                    resultImage.push("${env.BRANCH_NAME}")
                   }
                   }
                }  
            }

    stage('vote-build') {
       agent {
                docker {
                    image 'python:2.7.16-slim'
                    args '--user root'
                }
            }  
      when {
        changeset '**/vote/**'
      }
      steps {
        echo 'Compiling vote app.'
        dir(path: 'vote') {
          sh 'pip install -r requirements.txt'
        }

      }
    }

    stage('vote-test') {
       agent {
                docker {
                    image 'python:2.7.16-slim'
                    args '--user root'
                }
            } 
      when {
        changeset '**/vote/**'
      }
      steps {
        echo 'Running Unit Tests on vote app.'
        dir(path: 'vote') {
          sh 'pip install -r requirements.txt'
          sh 'nosetests -v'
        }

      }
    }

    stage('vote integration'){ 
        agent any 
        when{ 
            changeset "**/vote/**" 
            branch 'master' 
        } 
        steps{ 
            echo 'Running Integration Tests on vote app' 
            dir('vote'){ 
                sh 'sh integration_test.sh' 
            } 
        } 
    } 

    stage('vote-package-docker') {
             when {
              branch 'master'
              changeset "**/vote/**"
             }
            
             agent any
            
            steps {
                echo 'Packaging vote app with docker '
                script {
                    docker.withRegistry('https://registry-1.docker.io/v2/', 'dockerlogin'){
                    def voteImage = docker.build("hutinskit/vote:v${TAG_VOTE}", "./vote")
                    voteImage.push()
                    voteImage.push("${env.BRANCH_NAME}")
                    }
                }

            }
     }

    // stage('Sonarqube') {
    //   agent any
    //   when{
    //     branch 'master'
    //   }
    //   // tools {
    //    // jdk "JDK11" // the name you have given the JDK installation in Global Tool Configuration
    //  // }

    //   environment{
    //     sonarpath = tool 'SonarScanner'
    //   }

    //   steps {
    //         echo 'Running Sonarqube Analysis..'
    //         withSonarQubeEnv('sonar-instavote') {
    //           sh "${sonarpath}/bin/sonar-scanner -Dproject.settings=sonar-project.properties -Dorg.jenkinsci.plugins.durabletask.BourneShellScript.HEARTBEAT_CHECK_INTERVAL=86400"
    //         }
    //   }
    // }

    // stage("Quality Gate") {
    //     steps {
    //         sleep(10)
    //         timeout(time: 5, unit: 'MINUTES') {
    //             // Parameter indicates whether to set pipeline to UNSTABLE if Quality Gate fails
    //             // true = set pipeline to UNSTABLE, false = don't
    //             waitForQualityGate abortPipeline: true
    //         }
    //     }
    // }
    
    stage('deploy to dev on local pc, with docker-compose') {
      agent any
      when {
        branch 'master'
      }
      steps {
        echo 'Deploy new instavote app with docker compose'
        sh 'docker-compose up -d'
      }
    }

    stage('Deploy vote app with argo CD into k8s'){
            agent any
            steps {
                input message: "Approve deployment to production?"  
                dir("argocd-vote-deploy"){ deleteDir() }             
                sh '(git clone https://github.com/tinhutins/argocd-vote-deploy.git)'
                sh "(git config --global user.email 'tino.hutinski@gmail.com' && git config --global user.name 'thutinski')"
                dir("argocd-vote-deploy"){                
                sh "(git checkout master)"
                sh "(cd ./k8s-apps-deployment/k8s-spec-vote/ && kustomize edit set image docker.io/hutinskit/vote:v${TAG_VOTE})"
                sshagent(credentials: ['my-ssh-key', 'my-ssh-key2']) {
                  sh "(git pull origin master)"
                  sh "(git remote set-url origin git@github.com:tinhutins/argocd-vote-deploy.git)"
                  sh "(git commit -am 'Publish image  docker.io/hutinskit/vote:v${TAG_VOTE}' && git push origin master)"                 
                }
                deleteDir()
                }
            }
      } 
      stage('Deploy result app with argo CD into k8s'){
            agent any
            steps {
                dir("argocd-vote-deploy"){ deleteDir() }
                sh '(git clone https://github.com/tinhutins/argocd-vote-deploy.git)'
                sh "(git config --global user.email 'tino.hutinski@gmail.com' && git config --global user.name 'thutinski')"
                dir("argocd-vote-deploy"){                
                sh "(git checkout master)"
                sh "(cd ./k8s-apps-deployment/k8s-spec-result/ && kustomize edit set image docker.io/hutinskit/result:v${TAG_RESULT})"
                sshagent(credentials: ['my-ssh-key', 'my-ssh-key2']) {
                  sh "git remote set-url origin git@github.com:tinhutins/argocd-vote-deploy.git"
                  sh "git pull origin master"
                  sh "(git commit -am 'Publish image docker.io/hutinskit/result:v${TAG_RESULT}' && git push origin master)"
                }
                deleteDir()
                }
            }
      } 
      stage('Deploy worker app with argo CD into k8s'){
            agent any
            steps {
                dir("argocd-vote-deploy"){ deleteDir() }
                sh '(git clone https://github.com/tinhutins/argocd-vote-deploy.git)'
                sh "(git config --global user.email 'tino.hutinski@gmail.com' && git config --global user.name 'thutinski')"
                dir("argocd-vote-deploy"){                
                sh "(git checkout master)"
                sh "(cd ./k8s-apps-deployment/k8s-spec-worker/ && kustomize edit set image docker.io/hutinskit/worker:v${TAG_WORKER})"
                sshagent(credentials: ['my-ssh-key', 'my-ssh-key2']) {
                  sh "git remote set-url origin git@github.com:tinhutins/argocd-vote-deploy.git"
                  sh "git pull origin master"
                  sh "(git commit -am 'Publish image docker.io/hutinskit/worker:v${TAG_WORKER}' && git push origin master)"
                }
                deleteDir()
                }
            }
      } 
  } 
    post {
      always {
        echo 'Building whole mono pipeline for voting app is completed. There should be new images pushed on dockerhub and deployed locally with docker-compose and on k8s with argo.'
      }
    }
}
