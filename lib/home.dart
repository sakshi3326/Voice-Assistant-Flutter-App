import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:voice_assistant/feature_box.dart';
import 'package:voice_assistant/openai_service.dart';
import 'package:voice_assistant/pallete.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
   final speechToText = SpeechToText();
  final flutterTts = FlutterTts();
  String lastWords = '';
  final OpenAIService openAIService = OpenAIService();
  String? generatedContent;
  String? generatedImageUrl;
  int start = 200;
  int delay = 200;

  @override
  void initState() {
    super.initState();
    initSpeechToText();
    initTextToSpeech();
  }

  Future<void> initTextToSpeech() async {
    await flutterTts.setSharedInstance(true);
    setState(() {});
  }

  Future<void> initSpeechToText() async {
    await speechToText.initialize();
    setState(() {});
  }

  Future<void> startListening() async {
    await speechToText.listen(onResult: onSpeechResult);
    setState(() {});
  }

  Future<void> stopListening() async {
    await speechToText.stop();
    setState(() {});
  }

  void onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      lastWords = result.recognizedWords;
    });
  }

  Future<void> systemSpeak(String content) async {
    await flutterTts.speak(content);
  }

  @override
  void dispose() {
    super.dispose();
    speechToText.stop();
    flutterTts.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BounceInDown(child: const Text('Hello GPT')),
        leading: const Icon(Icons.menu),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ZoomIn(
              child: Stack(
                children: [
                  Center(
                    child: Container(
                      height: 120,
                      width: 120,
                      margin: const EdgeInsets.only(top: 4),
                      decoration: const BoxDecoration(
                        color: Pallete.assistantCircleColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Container(
                    height: 123,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage('assets/images/virtualAssistant.png',
                        )
                  
                      )
                    ),
                  )
                ],
              ),
            ),
            FadeInLeftBig(
              child: Visibility(
                visible: generatedImageUrl == null,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 40).copyWith(
                    top: 30,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Pallete.borderColor,
                    ),
                    borderRadius: BorderRadius.circular(20).copyWith(
                      topLeft: Radius.zero,
                      )
                  ),
                  child:  Text(
                    generatedContent == null ? 'Good Morning, what task can I do for you?' : generatedContent!,
                  style: TextStyle(
                    fontFamily: 'Cera-Pro',
                    color: Pallete.mainFontColor,
                    fontSize: generatedContent == null ? 24 : 18,
                  ),),
                ),
              ),
            ),
            if (generatedImageUrl != null) Padding(
              padding: const EdgeInsets.all(11.0),
              child: ClipRRect(borderRadius: BorderRadius.circular(20),child: Image.network(generatedImageUrl!)),
            ),
            SlideInLeft(
              child: Visibility(
                visible: generatedContent == null && generatedImageUrl == null,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.only(
                    top: 10,
                    left: 22,
                  ),
                  alignment: Alignment.centerLeft,
                  child: const Text('Here are few features', style: 
                  TextStyle(fontFamily: 'Cera-Pro',color: Pallete.mainFontColor,fontSize: 20,fontWeight: FontWeight.bold),),
                ),
              ),
            ),
      
            Visibility(
              visible: generatedContent == null && generatedImageUrl == null,

              child: Column(
                children:  [
                   SlideInLeft(
                    delay: Duration(milliseconds: start),
                     child: const FeatureBox(
                      color: Pallete.firstSuggestionBoxColor, 
                      headerText: 'ChatGpt', 
                      descriptionText: 'A smarter way to stay informed and organised with ChatGpt'
                      ),
                   ),
                    SlideInLeft(
                      delay: Duration(milliseconds: start + delay),

                      child: const FeatureBox(
                      color: Pallete.secondSuggestionBoxColor, 
                      headerText: 'Dall-E', 
                      descriptionText: 'Get inspired and stay creative with your personal assistant powered by Dall-E'
                      ),
                    ),
                    SlideInLeft(
                      delay: Duration(milliseconds: start + 2*delay),

                      child: const FeatureBox(
                      color: Pallete.thirdSuggestionBoxColor, 
                      headerText: 'Smart Voice Assistant', 
                      descriptionText: 'Get the best of both worlds with a voice assistant powered by Dall-E and ChatGPT'
                      ),
                    ),
                ],
              ),
            )
      
        ]),
      ),

      floatingActionButton: ZoomIn(
        child: FloatingActionButton(
          backgroundColor: Pallete.firstSuggestionBoxColor,
          onPressed: () async{
            if (await speechToText.hasPermission &&
                  speechToText.isNotListening) {
                await startListening();
              } else if (speechToText.isListening) {
                final speech = await openAIService.isArtPromptAPI(lastWords);
                if (speech.contains('https')) {
                  generatedImageUrl = speech;
                  generatedContent = null;
                  setState(() {});
                } else {
                  generatedImageUrl = null;
                  generatedContent = speech;
                  setState(() {});
                  await systemSpeak(speech);
                }
                await stopListening();
              } else {
                initSpeechToText();
              }
          },
        child:  Icon(speechToText.isListening ? Icons.stop : Icons.mic, color: Colors.black,),
        ),
      ),
    );
  }
}