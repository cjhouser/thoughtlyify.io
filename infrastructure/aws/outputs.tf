output "openbao_root_key_kms_id" {
  value = aws_kms_key.openbao.key_id
}
