resource "aws_iam_role" "lambda_role" {
  name = "lambda-authorizer-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_execution" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}



resource "null_resource" "package_lambda" {
  for_each = var.lambdas

  provisioner "local-exec" {
    command = <<EOT
    set -e
    REPO="${each.value.repository}"
    NAME="${each.key}"
    DIR="/tmp/$NAME"
    ZIP="/tmp/$NAME.zip"
    KEY_PATH="$HOME/.ssh/${each.value.ssh_key_name}"

    echo "Cloning $REPO into $DIR using $KEY_PATH"
    rm -rf $DIR && GIT_SSH_COMMAND="ssh -i $KEY_PATH -o StrictHostKeyChecking=no" git clone --depth 1 "$REPO" $DIR

    echo "Packaging Lambda $NAME"
    rm -f $ZIP
    cd $DIR && zip -r $ZIP . -x ".git/*" "__pycache__/*" > /dev/null
  EOT
  }


  triggers = {
    always_run = timestamp()
  }
}


resource "aws_lambda_function" "lambda_function" {
  for_each = var.lambdas

  function_name = each.key
  role          = aws_iam_role.lambda_role.arn
  runtime       = each.value.runtime
  handler       = each.value.handler
  architectures = [each.value.architectures]
  filename      = "/tmp/${each.key}.zip"

  timeout     = coalesce(each.value.timeout, 3)
  memory_size = each.value.memory_size != null ? each.value.memory_size : 128

  dynamic "ephemeral_storage" {
    for_each = each.value.ephemeral_storage != null ? [1] : []
    content {
      size = each.value.ephemeral_storage
    }
  }

  layers = each.value.layers != null ? each.value.layers : null

  environment {
    variables = each.value.environment_variables != null ? each.value.environment_variables : {}
  }

  depends_on = [
    null_resource.package_lambda,
    aws_iam_role_policy_attachment.lambda_execution
  ]
}
