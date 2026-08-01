package com.example.dayflow;

import android.os.Bundle;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.plugin.common.MethodChannel;
import java.util.TimeZone;

public class MainActivity extends FlutterActivity {
	private static final String CHANNEL = "dayflow/native_timezone";

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		new MethodChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(), CHANNEL)
				.setMethodCallHandler((call, result) -> {
					if (call.method.equals("getLocalTimezone")) {
						try {
							String tz = TimeZone.getDefault().getID();
							result.success(tz);
						} catch (Exception e) {
							result.error("UNAVAILABLE", "Could not get timezone", e.getMessage());
						}
					} else {
						result.notImplemented();
					}
				});
	}
}
