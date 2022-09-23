package com.example.native_code_calling;

import android.app.AlertDialog;
import android.content.ContextWrapper;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.BatteryManager;
import android.os.Build.VERSION;
import android.os.Build.VERSION_CODES;
import android.widget.Toast;

import androidx.annotation.NonNull;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {
    private static final String BATTERY_CHANNEL = "batteryChargeLevel";
    private static final String CHANNEL = "nativeChannel";
    private static final String DIALOGCHANNEL = "dialogChannel";

    public String answer = "неизвестно";

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {

        new MethodChannel(flutterEngine.getDartExecutor(), BATTERY_CHANNEL).setMethodCallHandler(
                (call, result) -> {
                    if (call.method.equals("getBatteryLevel")) {
                        int batteryLevel = getBatteryLevel();

                        if (batteryLevel != -1) {
                            result.success(batteryLevel);
                        } else {
                            result.error("UNAVAILABLE", "Battery level not available.", null);
                        }
                    } else {
                        result.notImplemented();
                    }
                }
        );

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler(
                        (call, result) -> {
                            if (call.method.equals("setToast")) {
                                String myText = call.argument("myText");
                                setText(myText);
                            }
                        }
                );

        new MethodChannel(flutterEngine.getDartExecutor(), DIALOGCHANNEL).setMethodCallHandler(
                (call, result) -> {
                    if (call.method.equals("dialogChannel")) {
                        String examResult = setDialog();
                        if (examResult != null) {
                            // result – MethodChannel.Result, используемый для отправки результата вызова.
                            result.success(examResult);
                        } else {
                            result.error("UNAVAILABLE", "Какая-то фигня с диалогом", null);
                        }
                    } else {
                        // Обрабатывает вызов нереализованного метода.
                        result.notImplemented();
                    }
                }
        );
    }

    public void setText(String myText) {
        Toast.makeText(this, myText, Toast.LENGTH_SHORT).show();
    }

    private int getBatteryLevel() {
        if (VERSION.SDK_INT >= VERSION_CODES.LOLLIPOP) {
            BatteryManager batteryManager = (BatteryManager) getSystemService(BATTERY_SERVICE);
            return batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY);
        } else {
            Intent intent = new ContextWrapper(getApplicationContext()).
                    registerReceiver(null, new IntentFilter(Intent.ACTION_BATTERY_CHANGED));
            return (intent.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) * 100) /
                    intent.getIntExtra(BatteryManager.EXTRA_SCALE, -1);
        }
    }

    public String setDialog() {
        new AlertDialog.Builder(this)
                .setTitle("Важный вопрос:")
                .setMessage("Получит ли Илья сегодня 13 грейд?")
                .setPositiveButton("Конечно да!", (dialog, which) -> {
                    Toast.makeText(getApplicationContext(),"Правильный ответ.",Toast.LENGTH_SHORT).show();
                    answer = "13 грейд, урра!!";
                })
                .setNegativeButton("нет", (dialog, which) -> {
                    answer = "12 грейд, быть такого не может...";
                    Toast.makeText(getApplicationContext(),"Ответ не засчитан! Переголосуйте.",Toast.LENGTH_SHORT).show();
                }).show();
        System.out.println(answer);
        return answer;
    }
}