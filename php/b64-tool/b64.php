<?php

/**
 * Base64 Encode/Decode CLI Tool
 *
 * Usage:
 *   php b64.php encode <string>              Encode a string
 *   php b64.php decode <string>              Decode a Base64 string
 *   php b64.php encode --url <string>        URL-safe Base64 encode
 *   php b64.php decode --url <string>        URL-safe Base64 decode
 *   php b64.php encode --file <path>         Encode file contents
 *   php b64.php decode --file <path>         Decode to a file (--output <path>)
 */

function encode(string $data, bool $urlSafe): string
{
    $encoded = base64_encode($data);
    if ($urlSafe) {
        $encoded = rtrim(strtr($encoded, '+/', '-_'), '=');
    }
    return $encoded;
}

function decode(string $data, bool $urlSafe): string
{
    if ($urlSafe) {
        $padding = strlen($data) % 4;
        if ($padding !== 0) {
            $data .= str_repeat('=', 4 - $padding);
        }
        $data = strtr($data, '-_', '+/');
    }

    $decoded = base64_decode($data, true);
    if ($decoded === false) {
        fwrite(STDERR, "Error: Invalid Base64 input.\n");
        exit(1);
    }
    return $decoded;
}

function readStdin(): string
{
    $data = '';
    while (!feof(STDIN)) {
        $data .= fread(STDIN, 8192);
    }
    return $data;
}

function main(array $argv): void
{
    array_shift($argv);

    if (empty($argv) || in_array('--help', $argv, true) || in_array('-h', $argv, true)) {
        echo "Usage: php b64.php <encode|decode> [--url] [--file <path>] [--output <path>] [string]\n";
        exit(0);
    }

    $command = array_shift($argv);

    if (!in_array($command, ['encode', 'decode'], true)) {
        fwrite(STDERR, "Error: Unknown command '{$command}'. Use 'encode' or 'decode'.\n");
        exit(1);
    }

    $urlSafe = false;
    $filePath = null;
    $outputPath = null;
    $input = null;

    while (!empty($argv)) {
        $arg = array_shift($argv);
        if ($arg === '--url') {
            $urlSafe = true;
        } elseif ($arg === '--file') {
            $filePath = array_shift($argv);
        } elseif ($arg === '--output') {
            $outputPath = array_shift($argv);
        } else {
            $input = $arg;
        }
    }

    $data = $filePath !== null
        ? file_get_contents($filePath)
        : ($input !== null ? $input : readStdin());

    if ($data === false) {
        fwrite(STDERR, "Error: Cannot read file '{$filePath}'.\n");
        exit(1);
    }

    $result = $command === 'encode'
        ? encode($data, $urlSafe)
        : decode($data, $urlSafe);

    if ($command === 'decode' && $outputPath !== null) {
        file_put_contents($outputPath, $result);
        echo "Decoded output written to {$outputPath}\n";
    } else {
        echo $result . "\n";
    }
}

main($argv);
