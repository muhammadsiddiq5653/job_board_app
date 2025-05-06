import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/job_model.dart';
import '../providers/job_provider.dart';
import '../providers/user_provider.dart';

class AddJobScreen extends StatefulWidget {
  const AddJobScreen({Key? key}) : super(key: key);

  @override
  _AddJobScreenState createState() => _AddJobScreenState();
}

class _AddJobScreenState extends State<AddJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _companyController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _companyController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    // Only recruiters should access this screen
    if (!userProvider.isRecruiter) {
      return Scaffold(
        appBar: AppBar(title: const Text('Access Denied')),
        body: const Center(
          child: Text('Only recruiters can add new jobs'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Job'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Job Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a job title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _companyController,
                decoration: const InputDecoration(
                  labelText: 'Company',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a company name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a location';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Job Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a job description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Consumer<JobProvider>(
                builder: (context, jobProvider, child) {
                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: jobProvider.isLoading
                          ? null
                          : () async {
                              if (_formKey.currentState!.validate()) {
                                // Create a new job
                                final newJob = Job(
                                  id: DateTime.now()
                                      .millisecondsSinceEpoch
                                      .toString(),
                                  title: _titleController.text,
                                  company: _companyController.text,
                                  location: _locationController.text,
                                  description: _descriptionController.text,
                                  postedBy: userProvider.currentUser?.id ?? '',
                                );

                                final success =
                                    await jobProvider.addJob(newJob);
                                if (success) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Job added successfully!'),
                                    ),
                                  );
                                  Navigator.pop(context);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Failed to add job'),
                                    ),
                                  );
                                }
                              }
                            },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: jobProvider.isLoading
                            ? const CircularProgressIndicator()
                            : const Text(
                                'Post Job',
                                style: TextStyle(fontSize: 16),
                              ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
