

# Output the CXX flags. These flags are propagated to sourceCpp via the 
# inlineCxxPlugin (defined below) and to packages via a line in Makevars[.win]
# like this:
#
#  PKG_CXXFLAGS += $(shell "${R_HOME}/bin${R_ARCH_BIN}/Rscript.exe" -e "RProtoBufLib::CxxFlags()")
#
CxxFlags <- function() {
   cat(pbCxxFlags())
}


# Output the LD flags for building against pb. These flags are propagated
# to sourceCpp via the inlineCxxPlugin (defined below) and to packages 
# via a line in Makevars[.win] like this:
#
#   PKG_LIBS += $(shell "${R_HOME}/bin${R_ARCH_BIN}/Rscript.exe" -e "RProtoBufLib::LdFlags()")
#
LdFlags <- function(...) {
   cat(pbLdFlags(...))
}

# alias for backward compatibility
RProtoBufLibLibs <- function() {
   LdFlags()
}


pbCxxFlags <- function() {
   
   flags <- c()
   
   
   flags
}

# Return the linker flags requried for pb on this platform
pbLdFlags <- function(all = TRUE) {
	gslibs <- system.file(file.path("lib", "GatingSet.pb.o"), package = "RProtoBufLib")
   # on Windows and Solaris we need to explicitly link against pb.dll
   if ((Sys.info()['sysname'] %in% c("Windows", "SunOS")) && !isSparc()) {
      pb <- pbLibPath()
      res <- paste("-L", asBuildPath(dirname(pb)), " -lprotobuf", sep = "")
   } else {
     res <- ""
   }
	if(all)
	  res <- paste(res, gslibs)
	res
}

# Determine the platform-specific path to the pb library
pbLibPath <- function(suffix = "") {
   sysname <- Sys.info()['sysname']
   pbSupported <- list(
      "Darwin" = paste("libprotobuf", suffix, ".dylib", sep = ""), 
      "Linux" = paste("libprotobuf", suffix, ".so.9", sep = ""), 
      "Windows" = paste("libprotobuf", suffix, ".dll", sep = ""),
      "SunOS" = paste("libprotobuf", suffix, ".so", sep = "")
   )
   # browser()
   if ((sysname %in% names(pbSupported)) && !isSparc()) {
      libDir <- "lib/"
      if (sysname == "Windows")
         libDir <- paste(libDir, .Platform$r_arch, "/", sep="")
      system.file(paste(libDir, pbSupported[[sysname]], sep = ""), 
                  package = "RProtoBufLib")
   } else {
      NULL
   }
}

isSparc <- function() {
   Sys.info()['sysname'] == "SunOS" && Sys.info()[["machine"]] != "i86pc"
}

# Helper function to ape the behavior of the R build system
# when providing paths to libraries
asBuildPath <- function(path) {
   if (.Platform$OS.type == "windows") {
      path <- normalizePath(path)
      if (grepl(' ', path, fixed=TRUE))
         path <- utils::shortPathName(path)
      path <- gsub("\\\\", "/", path)
   }
   return(path)
}