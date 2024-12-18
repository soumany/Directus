import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class GraphQLService {
  static final HttpLink httpLink = HttpLink(
    '${dotenv.env['DIRECTUS_API_URL']!}/graphql',
  );

  // Optional: Add authentication if needed
  static Link? getAuthLink() {
    final String? token = dotenv.env['DIRECTUS_TOKEN'];
    return token != null 
      ? AuthLink(getToken: () => 'Bearer $token')
      : null;
  }

  GraphQLClient createClient() {
    Link? authLink = getAuthLink();
    
    Link link = authLink != null 
      ? Link.concat(authLink, httpLink)
      : httpLink;

    return GraphQLClient(
      link: link,
      cache: GraphQLCache(store: InMemoryStore()),
    );
  }

  // Example query for articles
  String getArticlesQuery = r'''
    query {
      articles {
        id
        title
        content
        image {
          id
          filename_download
        }
      }
    }
  ''';

  // Generic method to execute a query
  Future<QueryResult> executeQuery(String query, {Map<String, dynamic>? variables}) async {
    final GraphQLClient client = createClient();

    final QueryOptions options = QueryOptions(
      document: gql(query),
      variables: variables ?? {},
    );

    return await client.query(options);
  }
}