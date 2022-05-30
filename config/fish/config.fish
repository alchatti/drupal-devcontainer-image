if status is-interactive
    # Commands to run in interactive sessions can go here
    oh-my-posh --init --shell fish --config /opt/.poshthemes/$POSH_THEME_ENVIRONMENT.omp.json | source
    startup.sh
end
