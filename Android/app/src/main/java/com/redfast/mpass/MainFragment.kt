package com.redfast.mpass

import android.app.AlertDialog
import android.app.UiModeManager
import android.content.Context
import android.content.res.Configuration
import android.graphics.Color
import android.os.Bundle
import android.util.DisplayMetrics
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.view.WindowManager
import android.widget.ImageView
import android.widget.LinearLayout
import androidx.appcompat.app.AppCompatActivity
import androidx.fragment.app.Fragment
import androidx.lifecycle.LifecycleOwner
import androidx.lifecycle.Observer
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.redfast.mpass.api.Video
import com.redfast.mpass.databinding.FragmentMainBinding
import com.redfast.mpass.viewModel.Genre
import com.redfast.mpass.viewModel.ViewModel
import com.redfast.promotion.InlineType
import com.redfast.promotion.PathItem
import com.redfast.promotion.PromotionManager
import com.redfast.promotion.PromotionResultCode
import com.squareup.picasso.Picasso
import kotlinx.android.synthetic.main.movie_cell.view.*
import kotlinx.android.synthetic.main.movie_row.view.*

class MovieCellHolder(v: View) : RecyclerView.ViewHolder(v) {
    init {
        itemView.setOnClickListener {
            val fragmentManager = (it.context as AppCompatActivity).supportFragmentManager
            val fragmentTransaction = fragmentManager.beginTransaction()
            val fragment = MovieFragment()
            fragmentTransaction.add(R.id.container, fragment, "Movie")
            fragmentTransaction.addToBackStack("Home")
            fragmentTransaction.commit()
        }
    }

    fun bindCell(video: Video, row: Int, cell: Int) {
        if (row == 0) {
            Picasso.get()
                .load(video.poster_path)
                .into(itemView.imageView2)
        } else {
            Picasso.get()
                .load("https://image.tmdb.org/t/p/w200" + video.poster_path)
                .into(itemView.imageView2)
        }
    }
}

class RecyclerCellAdapter(var list: List<Video>, var row: Int) : RecyclerView.Adapter<MovieCellHolder>() {
    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): MovieCellHolder {
        val view = LayoutInflater.from(parent.context).inflate(R.layout.movie_cell, null)
        view.isFocusable = true
        return MovieCellHolder(view)
    }

    override fun getItemCount(): Int {
        return list.count()
    }

    override fun onBindViewHolder(holder: MovieCellHolder, cell: Int) {
        holder.bindCell(list[cell], row, cell)
    }
}

class MovieRowHolder(private val viewModel: ViewModel, private val viewLifecycleOwner: LifecycleOwner, v: View) : RecyclerView.ViewHolder(v) {
    fun bindGenre(genre: Genre, position: Int) {
        itemView.textView4.text = genre.name
        itemView.movieCells.layoutManager =
            LinearLayoutManager(itemView.context, RecyclerView.HORIZONTAL, false)
        val movieCellAdapter = RecyclerCellAdapter(listOf(), position)
        itemView.movieCells.adapter = movieCellAdapter
        if (position == 0) {
            PromotionManager.getInlines(InlineType.featured) { featured ->
                movieCellAdapter.list = featured.map { Video(it.id, -1, it.actions.rf_settings_bg_image_android_os_phone_composite,"")}
                movieCellAdapter.notifyDataSetChanged()
            }
        } else {
            viewModel.loadGenreTVs(genre.id).observe(viewLifecycleOwner, Observer {
                movieCellAdapter.list = it
                movieCellAdapter.notifyDataSetChanged()
            })
        }
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
            holder.bindGenre(it, position)
        }
    }
}

class BillboardHolder(v: View) : RecyclerView.ViewHolder(v) {
    init {
        itemView.setOnClickListener {
            PromotionManager.getIapItems { list ->
                if (list.isNotEmpty()) {
                    val builder = AlertDialog.Builder(itemView.context)
                    builder.setTitle("InApp Purchase")
                    builder.setMessage("Do you want to purchase " + list[0].title + " for " + list[0].price)
                    builder.setPositiveButton("YES") { _, _ ->
                        PromotionManager.purchaseIap(list[0].sku!!) {
                            val fragmentManager = (v.context as AppCompatActivity).supportFragmentManager
                            val fragmentTransaction = fragmentManager.beginTransaction()
                            val fragment = MovieFragment()
                            fragmentTransaction.add(R.id.container, fragment, "Movie")
                            fragmentTransaction.addToBackStack("Home")
                            fragmentTransaction.commit()
                        }
                    }
                    builder.create().show()
                }
            }
        }
    }

    fun bindBillboard(url: String) {
        Picasso.get()
            .load(url)
            .into(itemView as ImageView)
    }
}

class BillboardsAdapter(private val context: Context, private val items: Array<PathItem>) : RecyclerView.Adapter<BillboardHolder>() {
    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): BillboardHolder {
        val view = ImageView(parent.context)
        view.layoutParams = LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.MATCH_PARENT)
        view.isFocusable = true
        return BillboardHolder(view)
    }

    override fun getItemCount(): Int {
        return items.size
    }

    override fun onBindViewHolder(holder: BillboardHolder, position: Int) {
        val uiModeManager = context.getSystemService(AppCompatActivity.UI_MODE_SERVICE) as UiModeManager
        var backgroundUrl= if (uiModeManager.currentModeType == Configuration.UI_MODE_TYPE_TELEVISION) {
            items[position].actions.rf_settings_bg_image_android_os_fire_tv_composite
        } else if (isTablet()) {
            items[position].actions.rf_settings_bg_image_android_os_tablet_composite
        } else {
            if (context.resources.configuration.orientation == Configuration.ORIENTATION_PORTRAIT)
                items[position].actions.rf_settings_bg_image_android_os_phone_composite
            else
                items[position].actions.rf_settings_bg_image_android_os_tablet_composite
        }
        backgroundUrl?.let {
            holder.bindBillboard(it)
        }
    }

    fun isTablet(): Boolean {
        val wm: WindowManager = context.getSystemService(Context.WINDOW_SERVICE) as WindowManager
        val displayMetrics = DisplayMetrics()
        wm.defaultDisplay.getMetrics(displayMetrics)
        val width = displayMetrics.widthPixels
        val height = displayMetrics.heightPixels
        val wi = width.toDouble() / displayMetrics.xdpi.toDouble()
        val hi = height.toDouble() / displayMetrics.ydpi.toDouble()
        val x = Math.pow(wi, 2.0)
        val y = Math.pow(hi, 2.0)
        val screenInches = Math.sqrt(x + y)
        return screenInches > 7
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
                    val allGenres = mutableMapOf<Int, Genre>()
                    allGenres[-1] = Genre(-1, "Promotion")
                    allGenres.putAll(it)
                    movieRowAdapter.collections = allGenres
                    movieRowAdapter.notifyDataSetChanged()
                })

                billboards.layoutManager = LinearLayoutManager(this@MainFragment.context, RecyclerView.HORIZONTAL, false)
                PromotionManager.getInlines(InlineType.billboard) {
                    billboards.adapter = BillboardsAdapter(this@MainFragment.context!!, it)
                }
            }
        binding.fragment = this
        binding.unsubscribe.setOnFocusChangeListener { view: View, hasFocus: Boolean ->
            if (hasFocus)
                view.setBackgroundColor(Color.WHITE)
            else
                view.setBackgroundColor(Color.TRANSPARENT)
        }
        binding.unsubscribe.requestFocus()
        PromotionManager.setScreenName(binding.root, "ViewController") {}
        return binding.root
    }

    fun onClick( view: View) {
        context?.let {
            PromotionManager.buttonClick(view, "accessibility-123") {
                when (it.code) {
                    PromotionResultCode.timerExpired,
                    PromotionResultCode.declined,
                    PromotionResultCode.abort ->
                        Log.v("mpass", "offer not selected")
                    PromotionResultCode.accepted ->
                        Log.v("mpass", "offer accepted")
                    else ->
                        Log.v("mpass", "not applicable")
                }
            }
        }
    }
}
