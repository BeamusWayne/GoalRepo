const args = process.argv.slice(2);

function showHelp(): void {
  console.log(`Usage: url-encode <encode|decode> <string>
       echo <string> | url-encode <encode|decode>

Options:
  -h, --help    Show this help message

Examples:
  url-encode encode "hello world"
  url-encode decode "hello%20world"
  echo "foo=bar&baz=1" | url-encode encode`);
}

function run(command: string, input: string): void {
  switch (command) {
    case "encode":
      console.log(encodeURIComponent(input));
      break;
    case "decode":
      try {
        console.log(decodeURIComponent(input));
      } catch {
        console.error("Error: Invalid percent-encoded string");
        process.exit(1);
      }
      break;
    default:
      console.error(`Error: Unknown command '${command}'. Use 'encode' or 'decode'.`);
      process.exit(1);
  }
}

if (args.includes("-h") || args.includes("--help")) {
  showHelp();
  process.exit(0);
}

if (args.length < 1) {
  showHelp();
  process.exit(1);
}

const command = args[0];

if (args.length >= 2) {
  run(command, args.slice(1).join(" "));
} else {
  const chunks: Buffer[] = [];
  process.stdin.on("data", (chunk: Buffer) => chunks.push(chunk));
  process.stdin.on("end", () => {
    const input = Buffer.concat(chunks).toString().trim();
    if (!input) {
      console.error("Error: No input provided");
      process.exit(1);
    }
    run(command, input);
  });
}
