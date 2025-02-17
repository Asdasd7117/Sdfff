package com.example.imageapp

import android.net.Uri
import android.os.Bundle
import android.widget.Button
import android.widget.ImageView
import androidx.activity.result.contract.ActivityResultContracts
import androidx.appcompat.app.AppCompatActivity
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup

class MainActivity : AppCompatActivity() {
    private lateinit var imageView: ImageView
    private lateinit var uploadButton: Button
    private lateinit var recyclerView: RecyclerView
    private val imageList = mutableListOf<ImageItem>()
    private lateinit var adapter: ImageAdapter

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        imageView = findViewById(R.id.imageView)
        uploadButton = findViewById(R.id.uploadButton)
        recyclerView = findViewById(R.id.recyclerView)
        
        adapter = ImageAdapter(imageList)
        recyclerView.layoutManager = LinearLayoutManager(this)
        recyclerView.adapter = adapter

        val getContent = registerForActivityResult(ActivityResultContracts.GetContent()) { uri: Uri? ->
            uri?.let {
                imageList.add(ImageItem(it, 0))
                adapter.notifyDataSetChanged()
            }
        }

        uploadButton.setOnClickListener {
            getContent.launch("image/*")
        }
    }
}

// Data class for images with like count
data class ImageItem(val uri: Uri, var likes: Int)

// Adapter for RecyclerView
class ImageAdapter(private val imageList: MutableList<ImageItem>) : RecyclerView.Adapter<ImageAdapter.ImageViewHolder>() {
    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ImageViewHolder {
        val view = LayoutInflater.from(parent.context).inflate(R.layout.image_item, parent, false)
        return ImageViewHolder(view)
    }

    override fun onBindViewHolder(holder: ImageViewHolder, position: Int) {
        val imageItem = imageList[position]
        holder.imageView.setImageURI(imageItem.uri)
        holder.likeButton.text = "Likes: ${imageItem.likes}"
        holder.likeButton.setOnClickListener {
            imageItem.likes++
            notifyDataSetChanged()
        }
    }

    override fun getItemCount(): Int = imageList.size

    class ImageViewHolder(view: View) : RecyclerView.ViewHolder(view) {
        val imageView: ImageView = view.findViewById(R.id.itemImageView)
        val likeButton: Button = view.findViewById(R.id.likeButton)
    }
}

// Codemagic configuration file
val codemagicYaml = """
workflows:
  android-app:
    name: Build Kotlin APK
    instance_type: mac_mini_m1
    max_build_duration: 60
    environment:
      vars:
        PROJECT_PATH: "app"
    scripts:
      - name: Clean and get dependencies
        script: |
          cd $PROJECT_PATH
          ./gradlew clean
          ./gradlew dependencies

      - name: Build APK
        script: |
          cd $PROJECT_PATH
          ./gradlew assembleRelease
    artifacts:
      - app/build/outputs/apk/release/app-release.apk
"""
