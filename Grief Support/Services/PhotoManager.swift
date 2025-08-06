//
//  PhotoManager.swift
//  Grief Support
//
//  Created by Claude on 8/6/25.
//

import Foundation
import UIKit

class PhotoManager {
    static let shared = PhotoManager()
    
    private let photosDirectory: URL
    
    private init() {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        photosDirectory = documentsPath.appendingPathComponent("Photos", isDirectory: true)
        
        // Create photos directory if it doesn't exist
        try? FileManager.default.createDirectory(at: photosDirectory, withIntermediateDirectories: true)
    }
    
    // MARK: - Save Photo
    
    func savePhoto(_ image: UIImage) -> String? {
        // Resize image to limit storage space
        let resizedImage = resizeImage(image, maxSize: CGSize(width: 1024, height: 1024))
        
        // Generate unique filename
        let filename = "\(UUID().uuidString).jpg"
        let fileURL = photosDirectory.appendingPathComponent(filename)
        
        // Convert to JPEG data with compression
        guard let imageData = resizedImage.jpegData(compressionQuality: 0.8) else {
            print("Failed to convert image to JPEG data")
            return nil
        }
        
        do {
            try imageData.write(to: fileURL)
            print("Successfully saved photo: \(filename)")
            return filename
        } catch {
            print("Failed to save photo: \(error)")
            return nil
        }
    }
    
    // MARK: - Load Photo
    
    func loadPhoto(_ filename: String) -> UIImage? {
        let fileURL = photosDirectory.appendingPathComponent(filename)
        
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            print("Photo file not found: \(filename)")
            return nil
        }
        
        return UIImage(contentsOfFile: fileURL.path)
    }
    
    // MARK: - Delete Photo
    
    func deletePhoto(_ filename: String) {
        let fileURL = photosDirectory.appendingPathComponent(filename)
        
        do {
            try FileManager.default.removeItem(at: fileURL)
            print("Successfully deleted photo: \(filename)")
        } catch {
            print("Failed to delete photo \(filename): \(error)")
        }
    }
    
    // MARK: - Cleanup
    
    func deletePhotosForRitual(_ ritual: SavedRitual) {
        if let photoFilename = ritual.photoFilename {
            deletePhoto(photoFilename)
        }
    }
    
    func getAllPhotoFilenames() -> [String] {
        do {
            let files = try FileManager.default.contentsOfDirectory(at: photosDirectory, 
                                                                   includingPropertiesForKeys: nil)
            return files.map { $0.lastPathComponent }
        } catch {
            print("Failed to get photo filenames: \(error)")
            return []
        }
    }
    
    // MARK: - Image Resizing
    
    private func resizeImage(_ image: UIImage, maxSize: CGSize) -> UIImage {
        let size = image.size
        
        // Don't resize if already within limits
        if size.width <= maxSize.width && size.height <= maxSize.height {
            return image
        }
        
        let widthRatio = maxSize.width / size.width
        let heightRatio = maxSize.height / size.height
        let ratio = min(widthRatio, heightRatio)
        
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext() ?? image
        UIGraphicsEndImageContext()
        
        return resizedImage
    }
}