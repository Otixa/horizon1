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
                sh 'lua $WORKSPACE/dependencies/dubuild/compiler.lua ./config/Compiler_Config.json -f "STEC.json" ./dependencies/dubuild/template.json ./output'
                sh 'lua $WORKSPACE/dependencies/dubuild/compiler.lua ./config/Compiler_Config.min.json -f "STEC.min.json" ./dependencies/dubuild/template.json ./output'
                sh 'lua $WORKSPACE/dependencies/dubuild/compiler.lua ./config/Compiler_Config.crypt.json -f "%s.STEC.crypt.json" ./dependencies/dubuild/template.json ./output'
                archiveArtifacts artifacts: './output/*.json', onlyIfSuccessful: true
            }
        }
    }
}