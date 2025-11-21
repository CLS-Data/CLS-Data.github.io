This folder contains the quarto (.qmd) files that are used to generate the markdown files for the webpages.

Use the following command (or similar) to render in the correct folders:

quarto::quarto_render("quarto/mcs-merging_across_sweeps.qmd", 
                      output_file = "mcs-merging_across_sweeps.md",
                      execute_dir = Sys.getenv("mcs_fld"))
                      
See also ../scripts/misc-extract_chunks.R for doing this programatically.