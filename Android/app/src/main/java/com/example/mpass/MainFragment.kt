package com.example.mpass

import android.app.AlertDialog
import android.graphics.Color
import android.os.Bundle
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import androidx.lifecycle.LifecycleOwner
import androidx.lifecycle.Observer
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.example.mpass.api.Video
import com.example.mpass.databinding.FragmentMainBinding
import com.example.mpass.viewModel.Genre
import com.example.mpass.viewModel.ViewModel
import com.redfast.promotion.PromotionManager
import com.redfast.promotion.PromotionResult
import com.squareup.picasso.Picasso
import kotlinx.android.synthetic.main.movie_cell.view.*
import kotlinx.android.synthetic.main.movie_row.view.*

class MovieCellHolder(v: View) : RecyclerView.ViewHolder(v) {
    fun bindCell(video: Video) {
        Picasso.get()
            .load( "https://image.tmdb.org/t/p/w200" + video.poster_path)
            .into(itemView.imageView2)
    }
}

class RecyclerCellAdapter(var list: List<Video>) : RecyclerView.Adapter<MovieCellHolder>() {
    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): MovieCellHolder {
        val view = LayoutInflater.from(parent.context).inflate(R.layout.movie_cell, null)
        return MovieCellHolder(view)
    }

    override fun getItemCount(): Int {
        return list.count()
    }

    override fun onBindViewHolder(holder: MovieCellHolder, position: Int) {
        holder.bindCell(list[position])
    }
}

class MovieRowHolder(private val viewModel: ViewModel, private val viewLifecycleOwner: LifecycleOwner, v: View) : RecyclerView.ViewHolder(v) {
    fun bindGenre(genre: Genre) {
        itemView.textView4.text = genre.name
        itemView.movieCells.layoutManager =
            LinearLayoutManager(itemView.context, RecyclerView.HORIZONTAL, false)
        val movieCellAdapter = RecyclerCellAdapter(listOf())
        itemView.movieCells.adapter = movieCellAdapter
        viewModel.loadGenreTVs(genre.id).observe(viewLifecycleOwner, Observer {
            movieCellAdapter.list = it
            movieCellAdapter.notifyDataSetChanged()
        })
    }
}

class RecyclerRowAdapter(private val viewModel: ViewModel, private val viewLifecycleOwner: LifecycleOwner, var collections: Map<Int, Genre>) : RecyclerView.Adapter<MovieRowHolder>() {
    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): MovieRowHolder {
        val view = LayoutInflater.from(parent.context).inflate(R.layout.movie_row, null)
        return MovieRowHolder(viewModel, viewLifecycleOwner, view)
    }

    override fun getItemCount(): Int {
        return collections.count()
    }

    override fun onBindViewHolder(holder: MovieRowHolder, position: Int) {
        val key = collections.keys.toTypedArray()[position]
        collections[key]?.let {
            holder.bindGenre(it)
        }
    }
}

class MainFragment : Fragment() {

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        val binding =
            FragmentMainBinding.inflate(inflater, container, false).apply {
                val viewModel = ViewModel(viewLifecycleOwner)
                val movieRowAdapter = RecyclerRowAdapter(viewModel, viewLifecycleOwner, mapOf())
                recyclerView.layoutManager = LinearLayoutManager(this@MainFragment.context)
                recyclerView.adapter = movieRowAdapter

                viewModel.loadGenres().observe(viewLifecycleOwner, Observer {
                    movieRowAdapter.collections = it
                    movieRowAdapter.notifyDataSetChanged()
                })
            }
        binding.fragment = this
        binding.playButton.setBackgroundColor(Color.WHITE)
        binding.playButton.requestFocus()
        PromotionManager.setScreenName(binding.root, "ViewController") {}
        return binding.root
    }

    fun onClick( view: View) {
        context?.let {
            PromotionManager.buttonClick(view, "accessibility-123") {
                when (it) {
                    PromotionResult.timerExpired,
                    PromotionResult.declined,
                    PromotionResult.abort ->
                        Log.v("mpass", "offer not selected")
                    PromotionResult.accepted ->
                        Log.v("mpass", "offer accepted")
                    else ->
                        Log.v("mpass", "not applicable")
                }
            }
        }
    }

    fun onFocus(view: View, hasFocus: Boolean) {
        if (hasFocus)
            view.setBackgroundColor(Color.WHITE)
        else
            view.setBackgroundColor(Color.TRANSPARENT)
    }
}