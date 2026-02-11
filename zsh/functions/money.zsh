# Money formatter
money() {
  awk '{printf("$%'\''0.2f\n", $1)}'
}
