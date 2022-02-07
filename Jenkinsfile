pipeline{
    agent any
    tools{
        maven 'T10'
    }
    environment{
        JAVA_HOME = '/usr/lib/jvm/java-11-openjdk-amd64'
    }
    stages{
        stage('Check-Git-Code'){
        steps{
            sh 'rm trufflehog || true'
            sh 'docker run gesellix/trufflehog --json https://github.com/abnavemangesh22/devsecwebapp.git > trufflehog'
            sh 'cat trufflehog'
        }
     }
    // stage('GitCheckout'){
      //   steps{
        //     git 'https://github.com/abnavemangesh22/devsecwebapp.git'
        // }
     //}
     stage('CodeCompile'){
         steps{
             
             sh '''
                export JAVA_HOME=$(dirname $(dirname $(readlink $(readlink $(which javac)))))
                export PATH=\$PATH:\$JAVA_HOME/bin
                export CLASSPATH=.:$JAVA_HOME/jre/lib:$JAVA_HOME/lib:$JAVA_HOME/lib/tools.jar
                mvn compile
                '''
         }
     }
     stage('CodeAnalysis'){
         steps{
             script{
                 withSonarQubeEnv('sonar') {
                   sh 'mvn sonar:sonar' 
                    }
                 timeout(time: 5, unit: 'HOURS') {
                    def qg = waitForQualityGate()
                    if(qg.status != 'OK'){
                        error "Pipeline aborted due to gate quality failure: ${qg.status}"
                    }
   
                 }   
             }
         }
     }
       stage('SourceCompositionAnalysis'){
         steps{
            sh 'rm owasp* || true'
            sh 'wget "https://raw.githubusercontent.com/cehkunal/webapp/master/owasp-dependency-check.sh"'
            sh 'chmod +x owasp-dependency-check.sh'
            sh 'bash owasp-dependency-check.sh'
           }
        }
      stage('BuildDonebyMaven'){
          steps{
              sh 'mvn package'
          }
      }
      stage('DockerBuild'){
          steps{
              script{
                 withCredentials([string(credentialsId: 'nexuspassword', variable: 'nexuspass')]) {
                  sh '''
                  docker build -t 35.236.47.74:8083/samruddh1 .
                  docker login -u admin -p $nexuspass 35.236.47.74:8083 
                  docker push 35.236.47.74:8083/samruddh1
                  docker rmi 35.236.47.74:8083/samruddh1
              ''' 
                 }
                 
              }
              
          }
         
      }
      stage('Manual Approval'){
          steps{
              script{
                  timeout(10){
                    mail bcc: '', body: "<br>Project: ${env.JOB_NAME} <br>Build Number: ${env.BUILD_NUMBER} <br> Go to build url and approve the deployment request <br> URL de build: ${env.BUILD_URL}", cc: '', charset: 'UTF-8', from: '', mimeType: 'text/html', replyTo: '', subject: "${currentBuild.result} CI: Project name -> ${env.JOB_NAME}", to: "tlouison@iqera.com";  
                    input(id: "Deploy Gate", message: "Deploy ${params.project_name}?", ok: 'Deploy') 
                  }
              }
          }
      }
      stage('DeployApplication'){
          steps{
              script{
                  sh '''
                  docker pull 35.236.47.74:8083/samruddh1
                  docker run -dit -P 35.236.47.74:8083/samruddh1
                  '''
              }
          }
      }
   }
    post {
		always {
			mail bcc: '', body: "<br>Project: ${env.JOB_NAME} <br>Build Number: ${env.BUILD_NUMBER} <br> URL de build: ${env.BUILD_URL}", cc: '', charset: 'UTF-8', from: '', mimeType: 'text/html', replyTo: '', subject: "${currentBuild.result} CI: Project name -> ${env.JOB_NAME}", to: "tlouison@iqera.com";  
		 }
	   }
}
