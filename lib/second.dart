import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SecondPage extends StatefulWidget {
    final int selectedDifficulty;

    SecondPage({Key? key, required this.selectedDifficulty}) : super(key: key);
    @override
    _SecondPage createState() => _SecondPage();
}

class _SecondPage extends State<SecondPage> {
    int difficulty = 0;
    final SpeechToText speech = SpeechToText();

    bool _hasSpeech = false;
    bool _logEvents = true;
    // onDevice=trueの場合、リッスンセッションはデバイス認識のみを使用する。
    // これができない場合、試聴は失敗する。
    // これは通常、プライバシーやセキュリティが懸念される機密性の高いコンテンツにのみ必要です。
    // falseの場合、リスンセッションはオンデバイス認識とネットワーク認識の両方を使用する。
    bool _onDevice = true;
    double level = 0.0;
    double minSoundLevel = 50000;
    double maxSoundLevel = -50000;
    String lastWords = '';
    String lastError = '';
    String lastStatus = '';
    String _currentLocaleId = 'ko_KR';    // https://docs.oracle.com/cd/E26924_01/html/E27144/glset.html

    @override
    void initState() {
        super.initState();

        difficulty = widget.selectedDifficulty;
    }

    // SpeechToTextを初期化する。
    // アプリの中で一度だけ実行する
    Future<void> initSpeechState() async {
        _logEvent('Initialize');
        try {
            var hasSpeech = await speech.initialize(
                onError: errorListener,
                onStatus: statusListener,
                debugLogging: _logEvents,
            );
            if (!mounted) return;

            setState(() {
                _hasSpeech = hasSpeech;
            });
        } catch (e) {
            setState(() {
                lastError = 'Speech recognition failed: ${e.toString()}';
                _hasSpeech = false;
            });
        }
    }
    
    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: Text("Difficulty => $difficulty"),
            ),
            body: Center(
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                        Text('word: $lastWords'),
                        Column(
                            children: [
                                InitSpeechWidget(_hasSpeech, initSpeechState),    // SpeechToText 初期化ボタン
                                SpeechControlWidget(_hasSpeech, speech.isListening, startListening, stopListening, cancelListening),
                                SessionOptionsWidget(
                                    _logEvents,
                                    _switchLogging,
                                    _onDevice,
                                    _switchOnDevice,
                                ),
                            ],
                        ),
                        TextButton(
                            onPressed: () {
                                Navigator.of(context).pop();
                            },
                            child: const Text("戻る")
                        )
                    ],
                )
            )
        );
    }

    // 'Start' ボタンを押したときの処理
    void startListening() {
        _logEvent('start listening');
        lastWords = '';
        lastError = '';
        final options = SpeechListenOptions(
                onDevice: _onDevice,
                listenMode: ListenMode.confirmation,
                cancelOnError: true,
                partialResults: true,
                autoPunctuation: true,
                enableHapticFeedback: true);
        speech.listen(
            onResult: resultListener,
            listenFor: Duration(seconds: 3),    // 固定
            pauseFor: Duration(seconds: 3),    // 固定
            localeId: _currentLocaleId,
            onSoundLevelChange: soundLevelListener,
            listenOptions: options,
        );
        setState(() {});
    }

    void stopListening() {
        _logEvent('stop');
        speech.stop();
        setState(() {
            level = 0.0;
        });
    }

    void cancelListening() {
        _logEvent('cancel');
        speech.cancel();
        setState(() {
            level = 0.0;
        });
    }

    /// このコールバックは `listen` が呼ばれた後、新しい認識結果が得られるたびに呼び出される。
    void resultListener(SpeechRecognitionResult result) {
        _logEvent('Result listener final: ${result.finalResult}, words: ${result.recognizedWords}');
        setState(() {
            lastWords = '${result.recognizedWords} - ${result.finalResult}';
        });
    }

    void soundLevelListener(double level) {
        minSoundLevel = min(minSoundLevel, level);
        maxSoundLevel = max(maxSoundLevel, level);
        // _logEvent('sound level $level: $minSoundLevel - $maxSoundLevel ');
        setState(() {
            this.level = level;
        });
    }

    void _logEvent(String eventDescription) {
        if (_logEvents) {
            var eventTime = DateTime.now().toIso8601String();
            debugPrint('$eventTime $eventDescription');
        }
    }

    void errorListener(SpeechRecognitionError error) {
        _logEvent('Received error status: $error, listening: ${speech.isListening}');
        setState(() {
            lastError = '${error.errorMsg} - ${error.permanent}';
        });
    }

    void statusListener(String status) {
        _logEvent('Received listener status: $status, listening: ${speech.isListening}');
        setState(() {
            lastStatus = status;
        });
    }

    void _switchLogging(bool? val) {
        setState(() {
            _logEvents = val ?? false;
        });
    }

    void _switchOnDevice(bool? val) {
        setState(() {
            _onDevice = val ?? false;
        });
    }
    
}

/// 'Start', 'Stop', 'Cancel' ボタン
class SpeechControlWidget extends StatelessWidget {
    const SpeechControlWidget(
        this.hasSpeech,
        this.isListening,
        this.startListening,
        this.stopListening,
        this.cancelListening,
        {Key? key}
    ): super(key: key);

    final bool hasSpeech;
    final bool isListening;
    final void Function() startListening;
    final void Function() stopListening;
    final void Function() cancelListening;

    @override
    Widget build(BuildContext context) {
        return Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
                TextButton(
                    onPressed: !hasSpeech || isListening ? null : startListening,
                    child: const Text('Start'),
                ),
                TextButton(
                    onPressed: isListening ? stopListening : null,
                    child: const Text('Stop'),
                ),
                TextButton(
                    onPressed: isListening ? cancelListening : null,
                    child: const Text('Cancel'),
                )
            ],
        );
    }
}

// 「Initialize」ボタン
// hasSpeech が初期化されてなかったら initSpeechState() する
class InitSpeechWidget extends StatelessWidget {
    const InitSpeechWidget(this.hasSpeech, this.initSpeechState, {Key? key})
            : super(key: key);

    final bool hasSpeech;
    final Future<void> Function() initSpeechState;

    @override
    Widget build(BuildContext context) {
        return Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
                TextButton(
                    onPressed: hasSpeech ? null : initSpeechState,
                    child: const Text('Initialize'),
                ),
            ],
        );
    }
}

class SessionOptionsWidget extends StatelessWidget {
    const SessionOptionsWidget(
            this.logEvents,
            this.switchLogging,
            this.onDevice,
            this.switchOnDevice,
            {Key? key})
            : super(key: key);

    final void Function(bool?) switchLogging;
    final void Function(bool?) switchOnDevice;
    final bool logEvents;
    final bool onDevice;

    @override
    Widget build(BuildContext context) {
        return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                    Row(
                        children: [
                            const Text('On device: '),
                            Checkbox(
                                value: onDevice,
                                onChanged: switchOnDevice,
                            ),
                            const Text('Log events: '),
                            Checkbox(
                                value: logEvents,
                                onChanged: switchLogging,
                            ),
                        ],
                    ),
                ],
            ),
        );
    }
}
