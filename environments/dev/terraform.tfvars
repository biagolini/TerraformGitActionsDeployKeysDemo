lambdas = {
  demo1 = {
    repository    = "git@github.com:biagolini/PythonAwsLambdaAuthorizer.git"
    runtime       = "python3.12"
    handler       = "lambda_function.lambda_handler"
    architectures = "arm64"
    ssh_key_name  = "key_01"
  }
  demo2 = {
    repository    = "git@github.com:biagolini/PythonAwsLambdaContainer.git"
    runtime       = "python3.12"
    handler       = "lambda_function.lambda_handler"
    architectures = "arm64"
    ssh_key_name  = "key_02"
    environment_variables = {
      DEMO_ENV_VAR = "demo_env_var"
    }
    memory_size       = 1024
    ephemeral_storage = 512
    timeout           = 5
  }
}
