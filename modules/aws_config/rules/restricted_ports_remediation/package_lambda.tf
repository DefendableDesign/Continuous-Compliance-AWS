data "archive_file" "lambda_remediation" {
    type = "zip"
    source_dir = "${path.module}/lambda_remediation"
    output_path = "${var.temp_dir}/DD_Config_Lambda_EC2_OpenPorts_Remediation.zip"
}
