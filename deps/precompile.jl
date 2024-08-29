using WannierCLI

# Hide stdout/err of these commands during installation
redirect_stdio(stdout=devnull, stderr=devnull) do
# Execute CLI once to generate precompile statements
    WannierCLI.command_main()

    # for (k, v) in WannierCLI.CASTED_COMMANDS
    #     @show v
    # end
end
