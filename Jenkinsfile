pipeline {

    agent {
        docker { image 'mhndev/docker-lua:latest'}
    }
    
    stages {
        stage('Cleanup') {
            steps {
                echo 'Clearing workspace'
                script {
                    deleteDir()
                }
            }
        }
        stage('Pull Source') {
            steps {
                echo 'Checking out source code'
                script {
                    checkout scm
                }
            }
        }
        stage('Build') {
            steps {
                sh 'cd $WORKSPACE'
                sh 'lua $WORKSPACE/dubuild/compiler.lua Compiler_Config.json ./dubuild/template.json STEC.json'
                sh 'lua $WORKSPACE/dubuild/compiler.lua Compiler_Config.min.json ./dubuild/template.json STEC.min.json'
                sh 'lua $WORKSPACE/dubuild/compiler.lua Compiler_Config.crypt.json ./dubuild/template.json STEC.crypt.json'
                archiveArtifacts artifacts: 'STEC*.json', onlyIfSuccessful: true
            }
        }
    }
}