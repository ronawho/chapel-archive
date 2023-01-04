/* The Computer Language Benchmarks Game
   https://salsa.debian.org/benchmarksgame-team/benchmarksgame/

   contributed by Brad Chamberlain
   based on the C gcc #8 version by Jeremy Zerfas
*/

use CTypes, IO;

param eol = '\n'.toByte(),  // end-of-line, as an integer
      cols = 61,            // # of characters per full row (including '\n')

      // A 'bytes' value that stores the complement of each base at its index
      cmpl = b"          \n                                                  "
           + b"    TVGH  CD  M KN   YSAABW R       TVGH  CD  M KN   YSAABW R";
             //    ↑↑↑↑  ↑↑  ↑ ↑↑   ↑↑↑↑↑↑ ↑       ↑↑↑↑  ↑↑  ↑ ↑↑   ↑↑↑↑↑↑ ↑
             //    ABCDEFGHIJKLMNOPQRSTUVWXYZ      abcdefghijklmnopqrstuvwxyz

// TODO: config param?
config param readSize = 65536,
             linesPerChunk = 8192,
             n = 0;

var pairCmpl: [0..<join(cmpl.size, cmpl.size)] uint(16);

var stdinBin  = openfd(0).reader(iokind.native, locking=false,
                                 hints=ioHintSet.fromFlag(QIO_CH_ALWAYS_UNBUFFERED)),
    stdoutBin = openfd(1).writer(iokind.native, locking=false,
                                 hints=ioHintSet.fromFlag(QIO_CH_ALWAYS_UNBUFFERED));

inline proc join(i:uint(16), j) {
  return i << 8 | j;
}

proc main(args: [] string) {
  const offs = eol..<cmpl.size;
  forall i in offs do
    forall j in offs do
      pairCmpl[join(i,j)] = join(cmpl(j), cmpl(i));

  var seqCap = readSize,
      totRead, seqSize = 0,
      seqDom = {0..<seqCap},
      seq: [seqDom] uint(8);

  do {
//    const more = stdinBin.read(seq[seqSize..#readSize]);
//    var bytesRead = stdinBin.offset() - totRead;
    var bytesRead = stdinBin.readBinary(c_ptrTo(seq[seqSize]), readSize);
//    totRead += readSize;
    totRead += bytesRead;
//    stderr.writef("read %i bytes\n", bytesRead);
    do {
//      stderr.writeln("Looking for sep in ", seqSize..#bytesRead);
      const seqStart = findSep(seq, seqSize, bytesRead);
      // TODO: any way to not duplicate check in this conditional and 'while'?
      // Should our while loops support variable declarations?
      if seqStart != -1 {
        const prevBytes = seqStart - seqSize;
        seqSize += prevBytes;

          revcomp(seq, seqSize);

//          stderr.writeln("Shifting from ", seqStart..#(bytesRead-prevBytes), " to ",
//                  0..<bytesRead-prevBytes);
          for j in 0..<bytesRead-prevBytes {
            seq[j] = seq[j+seqStart];
          }

          seqSize = 0;

        seqSize += 1;
        bytesRead -= prevBytes+1;
      }
    } while seqStart != -1;

    seqSize += bytesRead;

    if seqSize+readSize > seqCap {
      seqCap *= 2;
//      stderr.writeln("Doubling capacity to ", seqCap);
      seqDom = {0..<seqCap};
    }
//  } while more;
   } while bytesRead;

  if seqSize {
    revcomp(seq, seqSize);
  }
}

config const numTasks = here.maxTaskPar;

proc revcomp(seq, size) {
//  return;
  var i = 0;
  while seq[i] != eol {
    i += 1;
  }
  stdoutBin.write(seq[0..i]);
  //  stdoutBin.write(seq[i+1..<size]);
  var sharedCharsLeft, writtenChars: atomic int = size-(i+1);
  coforall tid in 0..<numTasks { // TODO: update to here.maxTaskPar {
    var chunkToWrite: [0..<linesPerChunk*cols] uint(8);
    do {
      var charsLeft = sharedCharsLeft.read(),
          chunkSize = linesPerChunk * cols;
      do {
        if charsLeft <= 0 then
          break;
//        writeln((charsLeft, linesPerChunk*cols));
//        stderr.writeln(tid, "trying to save ", charsLeft-chunkSize);
      } while !sharedCharsLeft.compareExchange(charsLeft, charsLeft-chunkSize);
//      writeln("Help: ", (charsLeft, sharedCharsLeft.read()));

      // TODO: This seems sloppy... is it because the compareExchange updates
      // charsLeft even when it succeeds?
//      charsLeft += chunkSize;

// TODO: Is this necessary, or is it guaranteed?
      if charsLeft > 0 {
        const fullLineFrontSpanLength = (charsLeft-1)%cols,
              fullLineRearSpanLength = cols-1-fullLineFrontSpanLength;

      if chunkSize > charsLeft {
        chunkSize = charsLeft;
      }

      var lastProc = charsLeft + i,  // sharedFront.fetchSub(chunkSize),
          chunkLeft = chunkSize;
//      stderr.writeln(tid, ": ", (fullLineFrontSpanLength, fullLineRearSpanLength, chunkSize, lastProc));

// TODO: Is this necessary, or is it guaranteed?
      if chunkLeft {
        var chunkPos = 0;

        if (!fullLineRearSpanLength) {
//        writeln("Calling with ", (chunkPos, lastProc, chunkLeft));
          revcompHelp(chunkPos, lastProc, chunkLeft, chunkToWrite, seq);
          chunkLeft = 0;
        }

        // TODO: Could this be a strided while loop?
        while (chunkLeft >= cols) {
//        writeln("B: Calling with ", (chunkPos, lastProc, chunkLeft));
          revcompHelp(chunkPos, lastProc, fullLineFrontSpanLength, chunkToWrite, seq);
          chunkPos += fullLineFrontSpanLength;
          lastProc -= fullLineFrontSpanLength+1;
          
//        writeln("C: Calling with ", (chunkPos, lastProc, chunkLeft));
          revcompHelp(chunkPos, lastProc, fullLineRearSpanLength, chunkToWrite, seq);
          chunkPos += fullLineRearSpanLength;
          lastProc -= fullLineRearSpanLength;
          
          chunkToWrite[chunkPos] = eol;
          chunkPos += 1;
          
          chunkLeft -= cols;
        }
        
        if (chunkLeft) {
//        writeln("D: Calling with ", (chunkPos, lastProc, chunkLeft));
          revcompHelp(chunkPos, lastProc, fullLineFrontSpanLength+1, chunkToWrite, seq);
        }

        // TODO: Need to coordinate here
        writtenChars.waitFor(charsLeft);
        stdoutBin.write(chunkToWrite[0..<chunkSize]);
        writtenChars.write(charsLeft-chunkSize);
      }
      }
    } while charsLeft > 0;  // TODO: This is part of the sloppiness mentioned above
//    } while charsLeft - chunkSize > 0;  // TODO: This is part of the sloppiness mentioned above
  }
}

  proc revcompHelp(in dstFront, in charAfter, in spanLen, chunkToWrite, seq) {
    if spanLen%2 {
      charAfter -= 1;
      chunkToWrite[dstFront] = cmpl[seq[charAfter]];
      dstFront += 1;
    }

    while (spanLen >= 2) {
      charAfter -= 2;
      const pair = ((c_ptrTo(seq[charAfter])):c_ptr(uint(16))).deref();
      const dest = c_ptrTo(chunkToWrite[dstFront]):c_ptr(uint(16));
      dest.deref() = pairCmpl[pair];
      spanLen -= 2;
      dstFront += 2;
    }
  }


// TODO: any clever way to avoid the inds.low conditional?
proc findSep(chunk: [?inds], low, count) {
  for i in low..#count {
    if chunk[i] == '>'.toByte() && i != inds.low {
//      stderr.writeln("Found sep at ", i);
      return i;
    }
  }
  return -1;
}
