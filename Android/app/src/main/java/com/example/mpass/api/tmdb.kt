package com.example.mpass.api

import androidx.annotation.Keep
import com.squareup.moshi.Json
import com.squareup.moshi.Moshi
import com.squareup.moshi.kotlin.reflect.KotlinJsonAdapterFactory
import okhttp3.OkHttpClient
import okhttp3.ResponseBody
import okhttp3.logging.HttpLoggingInterceptor
import retrofit2.Converter
import retrofit2.Response
import retrofit2.Retrofit
import retrofit2.converter.moshi.MoshiConverterFactory
import retrofit2.http.GET
import retrofit2.http.Query
import java.lang.reflect.Type
import java.util.concurrent.TimeUnit

const val QUERY_TAIL = "api_key=e3b287b40edd5313ba5318db511ee52a&language=en-US"

@Keep
data class Genre(
    @Json(name = "id") val id: Int,
    @Json(name = "name") val name: String
)

@Keep
data class Genres(
    @Json(name = "genres") val genres: List<Genre>
)

@Keep
data class Video(
    @Json(name = "name") val name: String,
    @Json(name = "id") val id: Int,
    @Json(name = "poster_path") var poster_path: String?,
    @Json(name = "overview") val overview: String
)

@Keep
data class Discover(
    @Json(name = "total_results") val total_results: Int,
    @Json(name = "results") val results: List<Video>
)

data class GenreVideos(
    val id: Int,
    val results: List<Video>
)

interface ITmdbApi {
    @GET("3/genre/tv/list?$QUERY_TAIL")
    suspend fun tvGetGenre(): Response<Genres>
    @GET("3/discover/tv?sort_by=popularity.desc&page=1&$QUERY_TAIL")
    suspend fun tvGetGenreCollection(@Query("with_genres")genreId: Int): Response<Discover>
}


open class TmdbApi {
    companion object UnitConverterFactory : Converter.Factory() {
        override fun responseBodyConverter(
            type: Type,
            annotations: Array<out Annotation>,
            retrofit: Retrofit): Converter<ResponseBody, *>? {
            return if (type == Unit::class.java) UnitConverter else null
        }

        private object UnitConverter : Converter<ResponseBody, Unit> {
            override fun convert(value: ResponseBody) {
                value.close()
            }
        }
    }

    private val baseUrl = "https://api.themoviedb.org/"

    private val serviceAPi: ITmdbApi = Retrofit.Builder()
        .baseUrl(baseUrl)
        .client(
            OkHttpClient.Builder()
                .addInterceptor(HttpLoggingInterceptor().apply { level = HttpLoggingInterceptor.Level.BODY })
                .readTimeout(120, TimeUnit.SECONDS)
                .build())
        .addConverterFactory(UnitConverterFactory)
        .addConverterFactory(
            MoshiConverterFactory.create(
                Moshi.Builder()
                    .add(KotlinJsonAdapterFactory())
                    .build()))
        .build().create(ITmdbApi::class.java)

    open suspend fun tvGetGenre(): Genres? {
        return serviceAPi.tvGetGenre().body()
    }

    open suspend fun tvGetGenreCollection(genreId: Int): GenreVideos? {
        return serviceAPi.tvGetGenreCollection(genreId).body()?.let {
            GenreVideos(genreId, it.results)
        }
    }
}