pipeline {
  agent any

  environment {
    deploymentName = "devsecops"
    containerName = "devsecops-container"
    serviceName = "devsecops-svc"
    imageName = "malonhiro/numeric-app:${GIT_COMMIT}"
    applicationURL = "http://20.127.143.197/"
    applicationURI = "/increment/99"
  }

  stages {
      stage('Build Artifact') {
            steps {
              sh "mvn clean package -DskipTests=true"
              archive 'target/*.jar'
            }
        }   
      stage('test') {
            steps {
              sh "mvn test"
            }
            post {
              always {
                junit 'target/surefire-reports/*.xml'
                jacoco execPattern: 'target/jacoco.exec'
              }
            }
        }
      stage('SAST') {
            steps {
              sh "mvn clean verify sonar:sonar -Dsonar.projectKey=numeric-application -Dsonar.host.url=http://20.127.143.197:9000 -Dsonar.login=sqp_b606e58a2a096d7b151046b26d7f6d7daa275f1b"
            }
        }
      stage('Vulnerability Scan') {
        steps {
          parallel(
            "Dependency Scan": {
              sh "mvn dependency-check:check"
            },
            "trivy Scan": {
              sh "bash trivy-docker-image-scan.sh"
            },
            "OPA Conftest": {
              sh 'docker run --rm -v $(pwd):/project openpolicyagent/conftest test --policy opa-docker-security.rego Dockerfile'
            }
          )
        }
        post {
          always {
            dependencyCheckPublisher pattern: 'target/dependency-check-report.xml'
          }
        }
       }    
      stage('Docker Build') {
        steps {
        withDockerRegistry([credentialsId:"docker-hub",url: ""]) {
              sh 'printenv'
              sh 'sudo docker build -t malonhiro/numeric-app:""$GIT_COMMIT"" .'
              sh 'docker push malonhiro/numeric-app:""$GIT_COMMIT""'
            }
        }   
      }
      stage('Mutation Tests') {
        steps {
          sh "mvn org.pitest:pitest-maven:mutationCoverage"
        }
        post {
          always {
            pitmutation mutationStatsFile: '**/target/pit-reports/**/mutations.xml'
          }
        }
      }
      stage('Vulnerability Scan - Kubernetes') {
        steps {
          parallel(
            "opa scan":{
              sh 'docker run --rm -v $(pwd):/project openpolicyagent/conftest test --policy opa-k8s-security.rego k8s_deployment_service.yaml'
            },
            "kubesec scan":{
              sh "bash kubesec-scan.sh"
            },
            "trivy scan":{
              sh "bash trivy-k8s-scan.sh"
            }
          )
        }
      }
      stage('Deploy') {
        steps {
          parallel(
            "Deployment": {
              withKubeConfig([credentialsId: 'kubeconfig']) {
                sh "bash k8s-deployment.sh"
              }
            },
            "Rollout-Status": {
              withKubeConfig([credentialsId: 'kubeconfig']) {
                sh "bash -x k8s-deployment-rollout-status.sh"
              }
            }
          )
        }
      }
      stage('OWASP ZAP - DAST') {
        steps {
          withKubeConfig([credentialsId: 'kubeconfig']) {
            sh 'bash zap.sh'
          }
        }
      }
  }
}