(define-actor (start-recording buffer)
    (let ((audio (pyAudio))
        (stream (open audio
                        format=pyaudio.paInt16
                        channels=CHANNELS
                        rate=FRAMERATE
                        input=True
                        frames_per_buffer=CHUNK_SIZE)))
        (start-actor 'record_audio (buffer stream))))

(define-actor (record_audio buffer stream)
    (forever
        (define data (stream 'read CHUNK_SIZE))
        (buffer 'append data)))

(define-actor (start_saving buffer queue)
    (start-actor 'process_frames_buffer (buffer queue)))

(define-actor (process_frames_buffer buffer queue)
    (forever
        (let* ((data-audio-dir "data/audio")
            (filename (string-append (number->string (current-seconds)) ".wav"))
            (filepath (string-append data-audio-dir "/" filename)))
            (if (not (directory-exists? data-audio-dir))
                (make-directory data-audio-dir))
            (save_audio buffer filepath)
            (queue 'put filepath)
            (buffer 'clear)
            (sleep DURATION))))
