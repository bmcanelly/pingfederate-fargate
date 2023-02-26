
resource aws_iam_role this {
  for_each = local.roles
  name               = each.value.name
  description        = each.value.description
  assume_role_policy = local.assume_role_policy
}

resource aws_iam_role_policy_attachment this {
  for_each = local.roles
  role       = aws_iam_role.this[each.key].name
  policy_arn = each.value.policy_arn
}
