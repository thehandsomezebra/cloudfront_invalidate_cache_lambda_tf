# cloudfront invalidate cache lambda tf
You want to invalidate your CloudFront Cache? You want to do this with a lambda?  You want to call that lambda with terraform? This is what I did.


---


1. Make a trust policy file named `trust-policy.json` with the following content (or just use my file).

```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
```

2. Run this to attach the above policy document to a brand new role.  I'm gunna call it `lambda-cloudfront-role`.

```
aws iam create-role --role-name lambda-cloudfront-role --assume-role-policy-document file://trust-policy.json
```

> NOTE: You will need to copy and paste the role arn into a notepad because we'll need it later...  It'll be something like `arn:aws:iam::123456789:role/lambda-cloudfront-role`


3. Add some role policies to the role.

This one allows the lambda to execute..
```
aws iam attach-role-policy --role-name lambda-cloudfront-role --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole
```

And this one gives the role full cloudfront access.

```
aws iam attach-role-policy --role-name lambda-cloudfront-role --policy-arn arn:aws:iam::aws:policy/CloudFrontFullAccess
```

*If giving full access doesn't suit you, You are welcome to create your own policy - just be sure it has `cloudfront:CreateInvalidation` .. read more on [https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/cf-api-permissions-ref.html](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/cf-api-permissions-ref.html)*


4. Grab the python file from this repo (`cfn-cache.py`). Zip it up.

```
zip -r9 lambda.zip cfn-cache.py
```



5. Now let's actually create the lambda.  You'll need that ARN for the role we made up in step 2.


```
aws lambda create-function --function-name lambda-cloudfront-invalidation --runtime python3.8 --handler cfn-cache.lambda_handler --zip-file --timeout 60 fileb://lambda.zip --role "arn:aws:iam::123456789:role/lambda-cloudfront-role"
```

6. Test it if you want.  Replace the Distribution ID with your actual distribution ID of your CloudFront.

```
aws lambda invoke --function-name lambda-cloudfront-invalidation --cli-binary-format raw-in-base64-out --payload '{  "DISTRIBUTION_ID": "ABC123ABC123" }' response.json
```


7. If you want it in your Terraform too, check out `main.tf`.


8. That's it. Every time that you run your terraform for your CloudFront... it will automatically run that lambda to invalidate the cache.  Because of the `triggers` of `always_run` - It'll force replacement on `aws_lambda_invocation.invoke_lambda`.  Never fear, it's not "replacing" -- it's just triggering a run of the lambda.  See [https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_invocation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_invocation) for more information on the "dynamic invocation".  The "always_run" snippet was from [https://ilhicas.com/2019/08/17/Terraform-local-exec-run-always.html](https://ilhicas.com/2019/08/17/Terraform-local-exec-run-always.html).


