object Main {
  def main(args: Array[String]): Unit = {
    if (args.isEmpty || args.contains("-h") || args.contains("--help")) {
      println("Usage: str-reverse [options] <string>")
      println("  --words   Reverse word order")
      println("  --chars   Reverse characters (default)")
      println("  --upper   Convert to uppercase")
      println("  --lower   Convert to lowercase")
      println("  --title   Convert to title case")
      return
    }

    val flags = args.takeWhile(_.startsWith("--")).toSet
    val text = args.dropWhile(_.startsWith("--")).mkString(" ")

    if (text.isEmpty) {
      println("Error: no input provided")
      return
    }

    var result = text
    if (flags.contains("--words"))
      result = result.split(" ").reverse.mkString(" ")
    if (flags.contains("--chars") || flags.isEmpty)
      result = result.reverse
    if (flags.contains("--upper"))
      result = result.toUpperCase
    if (flags.contains("--lower"))
      result = result.toLowerCase
    if (flags.contains("--title"))
      result = result.split(" ").map(_.capitalize).mkString(" ")
    println(result)
  }
}
