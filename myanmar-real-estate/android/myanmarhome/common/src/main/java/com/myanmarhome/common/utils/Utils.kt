package com.myanmarhome.common.utils

import java.text.NumberFormat
import java.text.SimpleDateFormat
import java.util.Locale

object FormatUtils {
    
    private val priceFormat = NumberFormat.getNumberInstance(Locale.US)
    
    fun formatPrice(price: java.math.BigDecimal): String {
        return priceFormat.format(price)
    }
    
    fun formatPriceWithUnit(price: java.math.BigDecimal, unit: String): String {
        return "${formatPrice(price)} $unit"
    }
    
    fun formatArea(area: Double): String {
        return "$area ㎡"
    }
    
    fun formatPhone(phone: String): String {
        // Format Myanmar phone numbers
        return when {
            phone.startsWith("+95") -> phone
            phone.startsWith("09") -> "+95${phone.substring(1)}"
            else -> phone
        }
    }
    
    fun maskPhone(phone: String): String {
        if (phone.length < 7) return phone
        return "${phone.take(3)}****${phone.takeLast(4)}"
    }
}

object DateUtils {
    
    private val apiDateFormat = SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.getDefault())
    private val displayDateFormat = SimpleDateFormat("yyyy年MM月dd日", Locale.getDefault())
    private val displayDateTimeFormat = SimpleDateFormat("MM月dd日 HH:mm", Locale.getDefault())
    
    fun formatApiDate(dateString: String?): String {
        if (dateString.isNullOrEmpty()) return ""
        return try {
            val date = apiDateFormat.parse(dateString)
            displayDateFormat.format(date!!)
        } catch (e: Exception) {
            dateString
        }
    }
    
    fun formatRelativeTime(dateString: String?): String {
        if (dateString.isNullOrEmpty()) return ""
        return try {
            val date = apiDateFormat.parse(dateString)
            val now = System.currentTimeMillis()
            val diff = now - date!!.time
            
            when {
                diff < 60 * 1000 -> "刚刚"
                diff < 60 * 60 * 1000 -> "${diff / (60 * 1000)}分钟前"
                diff < 24 * 60 * 60 * 1000 -> "${diff / (60 * 60 * 1000)}小时前"
                diff < 7 * 24 * 60 * 60 * 1000 -> "${diff / (24 * 60 * 60 * 1000)}天前"
                else -> displayDateFormat.format(date)
            }
        } catch (e: Exception) {
            dateString
        }
    }
}

object ValidationUtils {
    
    fun isValidMyanmarPhone(phone: String): Boolean {
        // Myanmar phone format: +959XXXXXXXXX or 09XXXXXXXXX
        val regex = Regex("^(\\+95|09)[0-9]{8,10}$")
        return regex.matches(phone)
    }
    
    fun isValidEmail(email: String): Boolean {
        return android.util.Patterns.EMAIL_ADDRESS.matcher(email).matches()
    }
    
    fun isValidVerifyCode(code: String): Boolean {
        return code.length == 6 && code.all { it.isDigit() }
    }
}
