download_to="./videos";
links="./videolinks.txt";
counter=0;

total=$(< "$links" wc -l);

mkdir -p "$download_to";
echo "Downloading 360 degree videos from youtube to $download_to";

while IFS=, read -r name link offset duration; do 
    let counter++
    echo "[Video $counter/$total]";
    if [ -f "$download_to/$name.mp4" ]; then
        echo "$counter/$total already downloaded...";
    else
        yt-dlp --user-agent "" "$link" -o "$download_to/$name-temp";
    fi
done < $links

while IFS=, read -r name link offset duration; do 
    ffmpeg \
            -ss $offset -i "$download_to/$name-temp.webm" \
            -preset faster \
            -vf "v360=c3x2:e:cubic:in_forder='lfrdbu':in_frot='000313',scale=3840:1920,setsar=1:1" \
            -t $duration -avoid_negative_ts 1 \
            "$download_to/$name.mp4" < /dev/null
    rm "$download_to/$name-temp.webm"
done < $links
