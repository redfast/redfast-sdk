package com.example.mpass.viewModel

import androidx.databinding.BaseObservable
import androidx.lifecycle.LifecycleOwner
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.Observer
import com.example.mpass.api.Video
import com.example.mpass.model.TmdbModels

data class Genre(
    val id: Int,
    val name: String
)

class ViewModel(private val lifecycleOwner: LifecycleOwner): BaseObservable() {
    private val model = TmdbModels()

    fun loadGenres(): LiveData<Map<Int, Genre>> {
        val collections = MutableLiveData<Map<Int, Genre>>()
        model.fetchTvGenres().observe(lifecycleOwner, Observer { genres ->
            val allGenres = mutableMapOf<Int, Genre>()
            genres.genres.forEach {
                val genre = Genre(it.id, it.name)
                allGenres[it.id] = genre
            }
            collections.value = allGenres
        })
        return collections
    }

    fun loadGenreTVs(genreId: Int): LiveData<List<Video>> {
        val collections = MutableLiveData<List<Video>>()
        model.fetchTvByGenre(genreId).observe(lifecycleOwner, Observer {
            collections.value = it.results
        })
        return collections
    }
}