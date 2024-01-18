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
      stage('Docker Build') {
        steps {
        withDockerRegistry([credentialsId:"docker-hub",url: ""]) {
              sh 'printenv'
              sh 'docker build -t malonhiro/numeric-app:""$GIT_COMMIT"" .'
              sh 'docker push malonhiro/numeric-app:""$GIT_COMMIT""'
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