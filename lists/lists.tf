locals {
  string = "value1,value2,value3,value4,value5"

  # use split to convert string to list
  list = split(",", local.string)

  first = local.list[0]

  # use length() -1 to get the last element of a list
  last = local.list[length(local.list) - 1]

  # use slice to remove the first and last
  slice = slice(local.list, 1, length(local.list) - 1)

  # use chunklist to split the list into lists of set length
  chunk = chunklist(local.list, 2)
}

output "out" {
  value = {
    string = local.string
    list   = local.list
    first  = local.first
    last   = local.last
    slice  = local.slice
    chunk  = local.chunk
  }
}
