Use the following command to execute render in the correct folders:

quarto_render("quarto/next_steps-test.qmd", 
              output_file = "next_steps-test.md",
              execute_dir = Sys.getenv("ns_fld"))