# Pokecard TCG

This is a flutter app I developed to learn flutter

## Developers

### Build the application

```bash
flutter build appbundle
```

### Connect to android device

```bash
adb pair 192.168.1.64:12345
# Enter code
adb connect 192.168.1.64:12345
```

### Generate database info when updating drift

To regenerate the code of the drift database perform:

```bash
dart run build_runner build -d
```
