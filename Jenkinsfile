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
        withDockerRegistry([credentialsID:"docker-hub",url: ""]) {
            steps {
              sh 'printenv'
              sh 'docker build -t malonhiro/numeric-app:""$GIT_COMMIT"" .'
              sh 'docker push malonhiro/numeric-app:""$GIT_COMMIT""'
            }
        }   
      }
    }
}