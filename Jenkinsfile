pipeline {
  agent any

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
              sh 'docker build -t malonhiro/numeric-app:""$GIT_COMMIT"" .'
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
      stage('Deploy') {
        steps {
        withKubeConfig([credentialsId:"kubeconfig"]) {
              sh "sed -i 's#replace#malonhiro/numeric-app:${GIT_COMMIT}#g' k8s_deployment_service.yaml"
              sh "kubectl apply -f k8s_deployment_service.yaml" 
            }
        }   
      }

  }
}