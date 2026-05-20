/**
 * Minimal QR code ASCII art generator.
 *
 * Generates a deterministic, visually unique grid pattern from input text
 * using a seeded PRNG. Useful as a recognizable visual hash / pseudo-QR
 * symbol for terminals. Not a standards-compliant QR encoder.
 *
 * Usage: kotlinc -script Main.kt [--size N] <text>
 */

fun main(args: Array<String>) {
    val parsed = parseArgs(args)
    if (parsed.text.isEmpty()) {
        println("Usage: qr-gen [--size <1-10>] <text>")
        return
    }
    val grid = QrGrid(text = parsed.text, scale = parsed.size)
    grid.render()
}

// --- CLI argument parsing ------------------------------------------------- //

data class Options(val text: String, val size: Int)

private fun parseArgs(args: Array<String>): Options {
    var size = 3
    var text = ""
    var i = 0
    while (i < args.size) {
        when {
            args[i] == "--size" && i + 1 < args.size -> {
                size = args[++i].toIntOrNull()?.coerceIn(1, 10) ?: 3
            }
            else -> text = buildString { if (isNotEmpty()) append(' '); append(args[i]) }
        }
        i++
    }
    return Options(text.trim(), size)
}

// --- Seeded PRNG (xorshift64) -------------------------------------------- //

class XorShift64(seed: Long) {
    private var state = if (seed == 0L) 0x1234567890ABCDEFL else seed

    fun next(): Long {
        var x = state
        x = x xor (x shl 13)
        x = x xor (x shr 7)
        x = x xor (x shl 17)
        state = x
        return x
    }

    fun nextBoolean(): Boolean = next() > 0
}

// --- QR grid generation -------------------------------------------------- //

class QrGrid(private val text: String, private val scale: Int = 3) {
    private val baseSize = 21
    private val size = baseSize + scale * 4

    private val full: BooleanGrid
    private val data: BooleanGrid

    init {
        val seed = text.fold(0L) { acc, c -> acc * 31L + c.code.toLong() }
        val rng = XorShift64(seed)

        full = BooleanGrid(size) { _, _ -> rng.nextBoolean() }

        data = BooleanGrid(size) { r, c ->
            val h = (r * 31L + c * 17L + seed).let { x ->
                var v = x; repeat(3) { v = v xor (v shl 13); v = v xor (v shr 7) }; v
            }
            val bit = text.codePointAt(((r * size + c) % text.length).let { if (it < 0) 0 else it })
            (h + bit) and 1L == 1L
        }
    }

    fun render() {
        val pattern = Array(size) { r -> CharArray(size) { c -> cell(r, c) } }

        // Quiet zone border
        val border = "  ".repeat(size + 2)
        println(border)
        for (row in pattern) {
            println("  ${row.joinToString("")}  ")
        }
        println(border)
    }

    private fun cell(r: Int, c: Int): Char = when {
        inFinderPattern(r, c, 0, 0) -> finderCell(r, c, 0, 0)
        inFinderPattern(r, c, 0, size - 7) -> finderCell(r, c, 0, size - 7)
        inFinderPattern(r, c, size - 7, 0) -> finderCell(r, c, size - 7, 0)
        inTiming(r, c) -> if ((r + c) % 2 == 0) FULL else EMPTY
        data[r][c] -> FULL
        else -> EMPTY
    }

    private fun inFinderPattern(r: Int, c: Int, pr: Int, pc: Int): Boolean =
        r in pr until pr + 7 && c in pc until pc + 7

    private fun finderCell(r: Int, c: Int, pr: Int, pc: Int): Char {
        val dr = r - pr; val dc = c - pc
        return if (dr in setOf(0, 6) || dc in setOf(0, 6)) FULL
        else if (dr in 2..4 && dc in 2..4) FULL
        else EMPTY
    }

    private fun inTiming(r: Int, c: Int): Boolean =
        (r == 6 && c in 8 until size - 8) || (c == 6 && r in 8 until size - 8)

    companion object {
        private const val FULL = '█'
        private const val EMPTY = ' '
    }
}

private typealias BooleanGrid = Array<BooleanArray>

private inline fun BooleanGrid(size: Int, init: (Int, Int) -> Boolean): BooleanGrid =
    Array(size) { r -> BooleanArray(size) { c -> init(r, c) } }

private fun String.codePointAt(index: Int): Int = if (index in indices) this[index].code else 0
