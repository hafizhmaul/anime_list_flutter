import 'package:anime_list/constants/colors.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:jikan_api/jikan_api.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isFavorited = true;
  late Future<List<Anime>> popularAnimeList;
  late Future<List<Anime>> airingAnimeList;

  @override
  void initState() {
    super.initState();
    popularAnimeList = fetchTopAnime();
    airingAnimeList = fetchAiringAnime();
  }

  Future<List<Anime>> fetchTopAnime() async {
    var baseUrl = 'https://api.jikan.moe/v4';
    var endpoint = '/top/anime';

    try {
      var response = await Dio().get(
        '$baseUrl$endpoint',
        queryParameters: {'type': 'tv', 'filter': 'bypopularity'},
      );

      List<dynamic> dataPopularAnime = response.data['data'];
      List<Anime> animeListPopular =
          dataPopularAnime.map((item) => Anime.fromJson(item)).toList();
      return animeListPopular;
    } catch (e) {
      throw Exception('$e');
    }
  }

  Future<List<Anime>> fetchAiringAnime() async {
    var baseUrl = 'https://api.jikan.moe/v4';
    var endpoint = '/seasons/now';

    try {
      var response = await Dio().get('$baseUrl$endpoint');

      List<dynamic> dataAiringAnime = response.data['data'];
      List<Anime> animeListAiring =
          dataAiringAnime.map((item) => Anime.fromJson(item)).toList();

      return animeListAiring;
    } catch (e) {
      throw Exception('$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: primaryBlack,
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              highlightAnime(context),
              airingAnime(),
              headerPopularAnime(),
              cardListPopularAnime(),
            ],
          ),
        ));
  }

  Widget cardListPopularAnime() {
    return FutureBuilder<List<Anime>>(
      future: popularAnimeList,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          List<Anime> animeList = snapshot.data!;
          return SizedBox(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: SingleChildScrollView(
                child: Column(
                  children: animeList.map((item) {
                    return cardAnimePopular(item);
                  }).toList(),
                ),
              ),
            ),
          );
        }
      },
    );
  }

  Column cardAnimePopular(Anime item) {
    return Column(children: [
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 120,
            height: 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              image: DecorationImage(
                  image: NetworkImage(item.imageUrl),
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15.0),
            child: Column(
              children: [
                SizedBox(
                  width: 200,
                  child: Text(
                    item.title,
                    textAlign: TextAlign.left,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: const TextStyle(
                        color: primaryWhite,
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                SizedBox(
                  width: 200,
                  child: Text(
                    '${item.year} \u{25CF} ${item.episodes} Episodes',
                    textAlign: TextAlign.left,
                    style: const TextStyle(color: lightGray, fontSize: 12.0),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                SizedBox(
                  width: 200,
                  height: 110,
                  child: Text(
                    item.synopsis ?? '',
                    textWidthBasis: TextWidthBasis.parent,
                    maxLines: 7,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.left,
                    style: const TextStyle(color: lightGray, fontSize: 12.0),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(
        height: 20.0,
      )
    ]);
  }

  Padding headerPopularAnime() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Popular',
                style: TextStyle(fontSize: 24, color: primaryWhite),
              ),
              Text(
                'See all',
                style: TextStyle(color: darkYellow, fontSize: 16),
              )
            ],
          ),
        ],
      ),
    );
  }

  Column airingAnime() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Text(
            'Currently Airing',
            style: TextStyle(
              color: primaryWhite,
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
        ),
        SizedBox(
          height: 250,
          child: FutureBuilder<List<Anime>>(
            future: airingAnimeList,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                List<Anime> airingList = snapshot.data!;
                return SizedBox(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: cardAiringList(airingList),
                    ),
                  ),
                );
              }
            },
          ),
        ),
      ],
    );
  }

  Row cardAiringList(List<Anime> airingList) {
    return Row(
      children: airingList.map((item) {
        return Row(
          children: [
            const SizedBox(
              width: 10.0,
            ),
            Column(
              children: [
                Container(
                  width: 140,
                  height: 180,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    image: DecorationImage(
                        image: NetworkImage(item.imageUrl),
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                SizedBox(
                  width: 140,
                  child: Text(
                    item.title,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: const TextStyle(
                        color: primaryWhite,
                        fontSize: 14,
                        fontWeight: FontWeight.w400),
                  ),
                ),
              ],
            ),
            const SizedBox(
              width: 5.0,
            )
          ],
        );
      }).toList(),
    );
  }

  Stack highlightAnime(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width,
          child: ShaderMask(
            shaderCallback: (Rect bounds) {
              return const LinearGradient(
                colors: [Colors.transparent, primaryBlack],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ).createShader(bounds);
            },
            blendMode: BlendMode.srcATop,
            child: Image.asset(
              'assets/img/header_anime.jpg',
              fit: BoxFit.cover,
              height: 410,
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Under the Oak Tree',
                  style: TextStyle(fontSize: 32.0, color: primaryWhite),
                ),
                const SizedBox(
                  height: 5.0,
                ),
                const Text(
                  'Romance \u{25CF} Fantasy \u{25CF} Free Pass',
                  style: TextStyle(color: lightGray, fontSize: 16.0),
                ),
                const SizedBox(
                  height: 5.0,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      backgroundColor: lightYellow),
                  onPressed: () {},
                  child: const Text(
                    'See Detail',
                    style:
                        TextStyle(fontWeight: FontWeight.w400, color: darkGray),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 40.0,
          right: 15.0,
          child: IconButton(
            onPressed: () {
              setState(() {
                isFavorited = !isFavorited;
              });
            },
            icon: isFavorited
                ? const Icon(Icons.favorite)
                : const Icon(Icons.favorite_outline_outlined),
            color: isFavorited ? lightYellow : primaryWhite,
            iconSize: 28.0,
          ),
        )
      ],
    );
  }
}
