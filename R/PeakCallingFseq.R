setClass(Class = "PeakCallingFseq",
         contains = "ATACProc"
)

setMethod(
    f = "initialize",
    signature = "PeakCallingFseq",
    definition = function(.Object,atacProc,..., bedInput=NULL,background=NULL,genomicReadsCount=NULL,
                          fragmentSize=0,featureLength=NULL,bedOutput=NULL,
                          fileformat=c("bed","wig","npf"), ploidyDir=NULL,
                          wiggleTrackStep=NULL,threshold=NULL,verbose=TRUE,
                          wgThresholdSet=NULL,editable=FALSE){
        .Object <- init(.Object,"PeakCallingFseq",editable,list(arg1=atacProc))
        if(!is.null(atacProc)){
            .Object@paramlist[["bedInput"]] <- getParam(atacProc,"bedOutput");
            .Object@paramlist[["bedFileList"]] <- basename(getParam(atacProc,"bedOutput"));
            .Object@paramlist[["inBedDir"]] <- dirname(getParam(atacProc,"bedOutput"));
            regexProcName<-sprintf("(BED|bed|Bed|%s)",getProcName(atacProc))
        }else{
            regexProcName<-"(BED|bed|Bed)"
        }

        if(!is.null(bedInput)){
            .Object@paramlist[["bedInput"]] <- bedInput;
            .Object@paramlist[["bedFileList"]] <- basename(bedInput)
            .Object@paramlist[["inBedDir"]] <- dirname(bedInput);
        }
        if(!is.null(bedOutput)){
            .Object@paramlist[["bedOutput"]] <-bedOutput
        }else{
            if(!is.null(.Object@paramlist[["bedInput"]])){
                prefix<-getBasenamePrefix(.Object,.Object@paramlist[["bedInput"]],regexProcName)
                .Object@paramlist[["bedOutput"]] <- file.path(.obtainConfigure("tmpdir"),paste0(prefix,".",getProcName(.Object),".bed"))
            }
            #.Object@paramlist[["bedOutput"]] <-paste(.Object@paramlist[["bedInput"]],".peak.bed",sep="");
        }
        .Object@paramlist[["outTmpDir"]] <- paste0(.Object@paramlist[["bedOutput"]],".tmp");

        .Object@paramlist[["background"]] <- background;
        .Object@paramlist[["genomicReadsCount"]] <- genomicReadsCount;
        .Object@paramlist[["fragmentSize"]] <- fragmentSize;
        .Object@paramlist[["featureLength"]] <- featureLength;
        .Object@paramlist[["fileformat"]] <- fileformat[1];
        .Object@paramlist[["ploidyDir"]] <- ploidyDir;
        .Object@paramlist[["wiggleTrackStep"]] <- wiggleTrackStep;
        .Object@paramlist[["threshold"]] <- threshold;
        .Object@paramlist[["verbose"]] <- verbose;
        .Object@paramlist[["wgThresholdSet"]] <- wgThresholdSet;


        paramValidation(.Object)
        .Object
    }
)

setMethod(
    f = "processing",
    signature = "PeakCallingFseq",
    definition = function(.Object,...){
        dir.create(.Object@paramlist[["outTmpDir"]])
        .fseq_call(bedFileList=.Object@paramlist[["bedFileList"]],
                   background=.Object@paramlist[["background"]],
                   genomicReadsCount=.Object@paramlist[["genomicReadsCount"]],
                   inputDir=.Object@paramlist[["inBedDir"]],
                   fragmentSize=.Object@paramlist[["fragmentSize"]],
                   featureLength=.Object@paramlist[["featureLength"]],
                   outputDir=.Object@paramlist[["outTmpDir"]],
                   outputFormat=.Object@paramlist[["fileformat"]],
                   ploidyDir=.Object@paramlist[["ploidyDir"]],
                   wiggleTrackStep=.Object@paramlist[["wiggleTrackStep"]],
                   threshold=.Object@paramlist[["threshold"]],
                   verbose=.Object@paramlist[["verbose"]],
                   wgThresholdSet=.Object@paramlist[["wgThresholdSet"]]);

        filename<-list.files(.Object@paramlist[["outTmpDir"]])
        for(i in 1:length(filename)){
            filename[i]<-strsplit(filename[i],split="\\.")[[1]][1]
        }
        peakfiles <- sort(filename)
        peakfiles<-paste0(peakfiles,".bed")
        peakfiles <- paste0(.Object@paramlist[["outTmpDir"]],"/",peakfiles)
        file.create(.Object@paramlist[["bedOutput"]])
        for(i in 1:length(peakfiles)){
            if(file.exists(peakfiles[i])&&file.info(peakfiles[i])$size>0){
                df <- read.table(peakfiles[i], header = FALSE,sep = "\t")
                df <- cbind(df,"*")
                write.table(x=df,file = .Object@paramlist[["bedOutput"]],append = TRUE,
                            quote = FALSE,sep = "\t",row.names = FALSE,col.names = FALSE)
            }
            #file.append(.Object@paramlist[["bedOutput"]],peakfiles[i])
        }
        #mergeFile(.Object@paramlist[["bedOutput"]],peakfiles)
        unlink(.Object@paramlist[["outTmpDir"]],recursive = TRUE,force = TRUE)


        .Object
    }
)

setMethod(
    f = "checkRequireParam",
    signature = "PeakCallingFseq",
    definition = function(.Object,...){
        if(is.null(.Object@paramlist[["bedInput"]])){
            stop("bedInput is required.")
        }
    }
)



setMethod(
    f = "checkAllPath",
    signature = "PeakCallingFseq",
    definition = function(.Object,...){
        checkFileExist(.Object,.Object@paramlist[["bedInput"]]);
        checkFileExist(.Object,.Object@paramlist[["background"]]);
        checkPathExist(.Object,.Object@paramlist[["ploidyDir"]]);
        checkFileCreatable(.Object,.Object@paramlist[["bedOutput"]]);
    }
)


#' @name PeakCallingFseq
#' @title Use F-seq to call peak
#' @description
#' Use F-seq to call peak
#' @param atacProc \code{\link{ATACProc-class}} object scalar.
#' It has to be the return value of upstream process:
#' \code{\link{atacSamToBed}},
#' \code{\link{atacBedUtils}}.
#' @param bedInput \code{Character} scalar.
#' BED file input path.
#' @param background \code{Character} scalar.
#' background directory default: NULL (none)
#' @param genomicReadsCount \code{Integer} scalar.
#' genomic count of sequence reads. default: NULL (calculated)
#' @param fragmentSize \code{Integer} scalar.
#' fragment size. set NULL to estimat from data. default:0
#' @param featureLength \code{Character} scalar.
#' feature length default: NULL (600)
#' @param bedOutput \code{Character} scalar.
#' the output bed file path
#' @param ploidyDir \code{Character} scalar.
#' ploidy/input directory. default: NULL
#' @param wiggleTrackStep \code{Integer} scalar.
#' wiggle track step default: NULL (1)
#' @param threshold \code{Numeric} scalar.
#' threshold (standard deviations) default: NULL (4.0)
#' @param verbose \code{Logical} scalar.
#' verbose output if TRUE.
#' @param wgThresholdSet \code{Character} scalar.
#' wg threshold set default: NULL (calculated)
#' @param ... Additional arguments, currently unused.
#' @details The parameter related to input and output file path
#' will be automatically
#' obtained from \code{\link{ATACProc-class}} object(\code{atacProc}) or
#' generated based on known parameters
#' if their values are default(e.g. \code{NULL}).
#' Otherwise, the generated values will be overwrited.
#' If you want to use this function independently,
#' you can use \code{peakCalling} instead.
#' @return An invisible \code{\link{ATACProc-class}} object scalar for downstream analysis.
#' @author Zheng Wei
#' @seealso
#' \code{\link{atacSamToBed}}
#' \code{\link{samToBed}}
#' \code{\link{atacBedUtils}}
#' \code{\link{bedUtils}}
#'
#' @examples
#' library(R.utils)
#' library(magrittr)
#' td <- tempdir()
#' options(atacConf=setConfigure("tmpdir",td))
#'
#' bedbzfile <- system.file(package="esATAC", "extdata", "chr20.50000.bed.bz2")
#' bedfile <- file.path(td,"chr20.50000.bed")
#' bunzip2(bedbzfile,destname=bedfile,overwrite=TRUE,remove=FALSE)
#'
#' bedUtils(bedInput = bedfile,maxFragLen = 100, chrFilterList = NULL) %>%
#' atacPeakCalling
#'
#' dir(td)


setGeneric("atacPeakCalling",function(atacProc,bedInput=NULL,background=NULL,genomicReadsCount=NULL,
                                         fragmentSize=0,featureLength=NULL,bedOutput=NULL,
                                         ploidyDir=NULL,#fileformat=c("bed","wig","npf"),
                                         wiggleTrackStep=NULL,threshold=NULL,verbose=TRUE,

                                         wgThresholdSet=NULL, ...) standardGeneric("atacPeakCalling"))

#' @rdname PeakCallingFseq
#' @aliases atacPeakCalling
#' @export
setMethod(
    f = "atacPeakCalling",
    signature = "ATACProc",
    definition = function(atacProc,bedInput=NULL,background=NULL,genomicReadsCount=NULL,
                          fragmentSize=0,featureLength=NULL,bedOutput=NULL,
                          ploidyDir=NULL,#fileformat=c("bed","wig","npf"),
                          wiggleTrackStep=NULL,threshold=NULL,verbose=TRUE,
                          wgThresholdSet=NULL, ...){
        peakcalling <- new("PeakCallingFseq",atacProc = atacProc,bedInput=bedInput,background=background,genomicReadsCount=genomicReadsCount,
                           fragmentSize=fragmentSize,featureLength=featureLength,bedOutput=bedOutput,fileformat="bed", ploidyDir=ploidyDir,
                           wiggleTrackStep=wiggleTrackStep,threshold=threshold,verbose=verbose,wgThresholdSet=wgThresholdSet)
        peakcalling<-process(peakcalling)
        invisible(peakcalling)
    }
)

#' @rdname PeakCallingFseq
#' @aliases peakCalling
#' @export
peakCalling <- function(bedInput,background=NULL,genomicReadsCount=NULL,
                            fragmentSize=0,featureLength=NULL,bedOutput=NULL,
                            ploidyDir=NULL,#fileformat=c("bed","wig","npf"),
                            wiggleTrackStep=NULL,threshold=NULL,verbose=TRUE,
                            wgThresholdSet=NULL, ...){
    peakcalling <- new("PeakCallingFseq",atacProc = NULL,bedInput=bedInput,background=background,genomicReadsCount=genomicReadsCount,
                       fragmentSize=fragmentSize,featureLength=featureLength,bedOutput=bedOutput,fileformat="bed", ploidyDir=ploidyDir,
                       wiggleTrackStep=wiggleTrackStep,threshold=threshold,verbose=verbose,wgThresholdSet=wgThresholdSet)
    peakcalling<-process(peakcalling)
    invisible(peakcalling)
}
