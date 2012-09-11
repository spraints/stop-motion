# Stop-motion scripts

These are scripts that I use when making stop-motion movies.
I have made stop-motion movies just with iMovie in the past,
but I wanted to see if it would be easier or better to make
them with ffmpeg. One thing I wanted was a faster-than-10fps
frame rate. I didn't end up using it, but I could have.

These scripts are ruby. I've only tried them with ruby 1.9.3.

## Example

Here's how my son and I made our stop-motion remake of
[toby and the flood](https://www.youtube.com/watch?v=_ZeROtaPp5A).
The movie's not that high of quality, but we were trying to
get something done quickly. Five year olds have a different idea
of acceptable quality than many older people do. :)


### 1. Take pictures

We started by taking pictures for all the scenes. My son came
up with all the shots to take, and we did the whole inch-by-inch
thing.

### 2. Record sound track

The only audio is narration. My son had the story memorized, so
I sat him down with a microphone and GarageBand, and went for a
walk. Later, I cut all the gaps and goofs.

### 3. Build scene list

I then made a list of
the scenes and their times, based on the audio. The list is a
set of directories, named like so:

    00.10.00s raining hard
    00.11.00s raining hard
    00.12.00s toby
    00.14.50s percy arrived
    00.19.75s percy and toby talking
    00.33.00s toby drives away
    00.39.75 harold inspects
    00.43.00s toby arrived
    00.49.00s toby on top of the dam
    00.54.00s backing down the dam
    ...

### 4. Sort photos

I moved the photos into the appropriate directories. The camera gave them
names that sort correctly, but aren't what I'd seen others use. The examples
I'd seen used names like `0036.jpg`. So, once you have all of the pictures
in a given directory, you can rename them all at once like this:

    ruby rename.rb '00.10.00s raining hard'/*

You can probably write a shell loop to run rename for each of the directories,
but it can be tricky to get it right if you put spaces in the filenames, like
I did.

### 5. Create movies for the scenes

Once we had the photos sorted, it was very obvious that some of the directories
had way too few pictures for the amount of time required. So I came up with
this system where I marked some of the directories to do special things with
the pictures.

I also didn't have a very large number of pictures, so even though I wanted to
use a faster frame rate than 10fps, I made the default 10fps.

The most obvious option is to drop the frame rate so that the available pictures
fill up the scene. This is what happens by default.

We can ignore the mismatch in frames and length, and just make the shorter (or
longer) scene. I did this in a couple of places where I could fudge the length of
surrounding scenes. To mark these scenes, I created an empty file called `NORMAL`
in the scene's directory.

Another option is to loop the video. For some of the scenes, I had taken a set of
pictures of the same thing, like when the characters are talking and there's
no action. To mark these scenes, I created an empty file named `LOOP` in the
directory.

For some scenes, I just wanted the pictures to flip by more slowly. These were
going to be 3fps. I created an empty file called `SLOW` in the scene's directory
to mark these scenes.

To process the movies, I ran `splice.rb`. (I apologize if that's not the right name
for what it's doing.)

    >> ls
    00.10.00s raining hard                        01.49.25 toby floats
    00.11.00s raining hard                        01.56.00 beware the waterfall
    00.12.00s toby                                01.59.00 if we go over
    00.14.50s percy arrived                       02.03.00 harold swoops in
    00.19.75s percy and toby talking              02.10.25 attach rope
    00.33.00s toby drives away                    02.14.00 percy arrived
    00.39.75 harold inspects                      02.21.00 percy is pulling
    00.43.00s toby arrived                        02.30.50 toby was safe
    00.49.00s toby on top of the dam              02.35.00 flood over and dam mended
    00.54.00s backing down the dam                02.39.50 big party
    01.03.25 percy waiting                        02.59.50 the end
    01.07.50 toby says dam is breaking up         03.01.00 end of audio
    01.17.50 percy says only chance is to cross   README.md
    01.21.75 toby crosses                         out
    01.32.50 dam breaks 01.34.25 is the big break rename.rb
    01.37.00 toby yells help                      splice.rb
    01.41.50 percy will follow

    >> ruby splice.rb
    ffmpeg -y -loop_input -vframes 11 -r 10 -i %03d.jpg ../out/00.10.00s raining hard.mp4
    ffmpeg -y -loop_input -vframes 11 -r 10 -i %03d.jpg ../out/00.11.00s raining hard.mp4
    ffmpeg -y -loop_input -vframes 26 -r 10 -i %03d.jpg ../out/00.12.00s toby.mp4
    ffmpeg -y -r 1 -i %03d.jpg ../out/00.14.50s percy arrived.mp4
    ffmpeg -y -loop_input -vframes 133 -r 10 -i %03d.jpg ../out/00.19.75s percy and toby talking.mp4
    ffmpeg -y -r 1 -i %03d.jpg ../out/00.33.00s toby drives away.mp4
    ffmpeg -y -r 10 -i %03d.jpg ../out/00.39.75 harold inspects.mp4
    ffmpeg -y -r 10 -i %03d.jpg ../out/00.43.00s toby arrived.mp4
    ffmpeg -y -loop_input -vframes 51 -r 10 -i %03d.jpg ../out/00.49.00s toby on top of the dam.mp4
    ffmpeg -y -r 10 -i %03d.jpg ../out/00.54.00s backing down the dam.mp4
    ffmpeg -y -r 1 -i %03d.jpg ../out/01.03.25 percy waiting.mp4
    ffmpeg -y -loop_input -vframes 101 -r 10 -i %03d.jpg ../out/01.07.50 toby says dam is breaking up.mp4
    ffmpeg -y -r 3 -i %03d.jpg ../out/01.21.75 toby crosses.mp4
    ffmpeg -y -r 1 -i %03d.jpg ../out/01.32.50 dam breaks 01.34.25 is the big break.mp4
    ffmpeg -y -r 1 -i %03d.jpg ../out/01.37.00 toby yells help.mp4
    ffmpeg -y -r 1 -i %03d.jpg ../out/02.21.00 percy is pulling.mp4
    ffmpeg -y -loop_input -vframes 46 -r 10 -i %03d.jpg ../out/02.35.00 flood over and dam mended.mp4

When you run it, the output from ffmpeg will show up between the ffmpeg
commands. Also, even though it's not outputting commands that you could
paste into your shell, it is actuallly handling spaces in file names
correctly.

If you need to change a setting (e.g. add a LOOP or NORMAL file, or change pictures),
you can reprocess a single scene:

    >> ruby splice.rb 00.19.75s\ percy\ and\ toby\ talking
    ffmpeg -y -loop_input -vframes 133 -r 10 -i %03d.jpg ../out/00.19.75s percy and toby talking.mp4

### 6. Assemble

Now that you have all the individual segments, open up iMovie and put them all
together! If you're more awesome than I am, and get the right number of
pictures for all the scenes, you can probably have ffmpeg do it.
