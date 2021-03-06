#' Extract (spliced or unspliced) transcript sequences
#'
#' @param gtf The path to a gtf file
#' @param genome A \code{DNAStringSet} object with the genome sequence
#' @param type Either 'spliced' or 'unspliced'
#' @param verbose Logical, whether or not to print messages
#'
#' @return A \code{DNAStringSet} object with intronic sequences
#' @export
#' @author Charlotte Soneson
#'
#' @importFrom GenomicFeatures extractTranscriptSeqs makeTxDbFromGFF exonsBy
#'
extractTxSeqs <- function(gtf, genome, type = c("spliced", "unspliced"), verbose = TRUE) {
    type <- match.arg(type)
    
    if (!is.character(gtf) || length(gtf) != 1 || !file.exists(gtf)) {
        stop("'gtf' must be a character scalar providing ", 
             "the path to an existing file.")
    }
    if (!is(genome, "DNAStringSet")) {
        stop("'genome' must be a DNAStringSet")
    }
    if (!is.logical(verbose) || length(verbose) != 1) {
        stop("'verbose' must be a logical scalar")
    }
    
    if (verbose) {
        message("Extracting ", type, " transcript sequences")
    }

    ## Construct TxDb from gtf file
    txdb <- GenomicFeatures::makeTxDbFromGFF(gtf, format = "gtf")
    
    ## Group exons by transcript. When using exonsBy with by = "tx", 
    ## the returned exons are ordered by ascending rank for each transcript, 
    ## that is, by their position in the transcript. 
    grl <- GenomicFeatures::exonsBy(txdb, by = "tx", use.names = TRUE)
    
    ## Extract transcript sequences.
    ## Here, it's important that for each transcript, the exons must be ordered 
    ## by ascending rank, that is, by ascending position in the transcript.
    if (type == "spliced") {
        txout <- GenomicFeatures::extractTranscriptSeqs(x = genome, transcripts = grl)
    } else if (type == "unspliced") {
        txout <- GenomicFeatures::extractTranscriptSeqs(x = genome, transcripts = range(grl))
    } else {
        stop("Unknown 'type' argument")
    }
    
    return(txout)
}
