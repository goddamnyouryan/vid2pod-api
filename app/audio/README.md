# Audio Files

This directory contains audio files used by the application.

## intro.mp3

The podcast intro that gets prepended to all downloaded videos.

**Current intro**: "YouTube video brought to you as a podcast from vid2pod.fm"

### How it was created

The current intro.mp3 was generated using macOS `say` command and `ffmpeg`:

```bash
# 1. Create a simple two-tone jingle (0.4 seconds)
ffmpeg -y -f lavfi -i "sine=frequency=800:duration=0.2" \
       -f lavfi -i "sine=frequency=1000:duration=0.2" \
       -filter_complex "[0:a][1:a]concat=n=2:v=0:a=1,volume=0.5" \
       -ar 44100 -ac 2 -b:a 192k /tmp/jingle.mp3

# 2. Generate voice using macOS text-to-speech
say -v Samantha "YouTube video brought to you as a podcast from vid2pod.fm" \
    -o /tmp/intro_voice.aiff

# 3. Convert voice to MP3
ffmpeg -y -i /tmp/intro_voice.aiff -ar 44100 -ac 2 -b:a 192k /tmp/intro_voice.mp3

# 4. Concatenate jingle and voice
cat > /tmp/concat_intro.txt << 'EOF'
file '/tmp/jingle.mp3'
file '/tmp/intro_voice.mp3'
EOF

ffmpeg -y -f concat -safe 0 -i /tmp/concat_intro.txt -c:a libmp3lame -b:a 192k app/audio/intro.mp3
```

**Result**: ~4 second intro with two-tone jingle + voice

### Replacing the intro

To use a different intro:

1. Replace `app/audio/intro.mp3` with your custom audio file
2. Ensure it's in MP3 format
3. Recommended: Keep it short (3-10 seconds)
4. The intro will automatically be applied to all new video downloads
5. To reprocess existing videos with the new intro:
   ```ruby
   # In Rails console
   video.redownload!
   ```

### Technical details

- The intro is automatically prepended to all downloaded videos via `AudioSplicer` service
- Uses ffmpeg concat demuxer with `-c copy` (no re-encoding)
- If intro.mp3 doesn't exist, videos are downloaded without an intro (no errors)
- See `app/services/audio_splicer.rb` for implementation details
