cd "./render copy"
IFS=$'\n' # the input field separators include space by default
i=1
for f in $(ls -r frame_*.png); do 
    mv "$f" "frame_$(printf %04d $((571+i)))".png
    (( i++ ))
done
