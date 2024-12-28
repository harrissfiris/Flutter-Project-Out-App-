import 'package:flutter/material.dart';


class CustomSearchBar extends StatefulWidget {
 final Future<List<String>> Function(String query) onSearch;
 final void Function(String) onResultTap;
 final String hintText;


 const CustomSearchBar({
   super.key,
   required this.onSearch,
   required this.onResultTap,
   this.hintText = 'Search...',
 });


 @override
 State<CustomSearchBar> createState() => _CustomSearchBarState();
}


class _CustomSearchBarState extends State<CustomSearchBar> {
 final TextEditingController _controller = TextEditingController();
 List<String> _searchResults = [];
 bool _isSearching = false;


 void _performSearch(String query) async {
   if (query.isEmpty) {
     setState(() {
       _searchResults = [];
     });
     return;
   }
   setState(() {
     _isSearching = true;
   });


   final results = await widget.onSearch(query);


   setState(() {
     _searchResults = results;
     _isSearching = false;
   });
 }


 @override
 Widget build(BuildContext context) {
   return Column(
     crossAxisAlignment: CrossAxisAlignment.start,
     children: [
       // Search Field
       Padding(
         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
         child: TextField(
           controller: _controller,
           onChanged: _performSearch,
           decoration: InputDecoration(
             icon: const Icon(Icons.search),
             suffixIcon: IconButton(
               icon: const Icon(Icons.close),
               onPressed: () {
                 _controller.clear();
                 _performSearch('');
               },
             ),
             border: OutlineInputBorder(
               borderRadius: BorderRadius.circular(8),
             ),
             hintText: widget.hintText,
           ),
         ),
       ),
       if (_isSearching) const Center(child: CircularProgressIndicator()),
       if (_searchResults.isNotEmpty)
         Expanded(
           child: ListView.builder(
             itemCount: _searchResults.length,
             itemBuilder: (context, index) {
               final result = _searchResults[index];
               final query = _controller.text;


               return ListTile(
                 title: _buildHighlightedText(result, query),
                 onTap: () {
                   widget.onResultTap(result);
                 },
               );
             },
           ),
         ),
     ],
   );
 }


 /// Highlights matching text in bold
 Widget _buildHighlightedText(String text, String query) {
   if (query.isEmpty) {
     return Text(text); // Return plain text if query is empty
   }


   final matches = <TextSpan>[];
   final textLower = text.toLowerCase();
   final queryLower = query.toLowerCase();
   int start = 0;


   // Find matches and build TextSpans
   while (start < text.length) {
     final matchStart = textLower.indexOf(queryLower, start);
     if (matchStart == -1) {
       matches.add(TextSpan(
         text: text.substring(start),
         style: const TextStyle(fontWeight: FontWeight.normal),
       ));
       break;
     }
     if (matchStart > start) {
       matches.add(TextSpan(
         text: text.substring(start, matchStart),
         style: const TextStyle(fontWeight: FontWeight.normal),
       ));
     }
     final matchEnd = matchStart + query.length;
     matches.add(TextSpan(
       text: text.substring(matchStart, matchEnd),
       style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
     ));
     start = matchEnd;
   }


   return RichText(
     text: TextSpan(
       children: matches,
       style: const TextStyle(color: Colors.black), // Default style for normal text
     ),
   );
 }
}








